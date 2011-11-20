#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cerrno>
#include <cstring>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>
#include <sys/time.h>

#include <stdexcept>
#include <utility>
#include <map>
#include <vector>

#define BACKLOG 10     // how many pending connections queue will hold



//Simplified reactor Pattern around basic select()
class EventHandler //event handlers
{
public:
    virtual int handleIncoming() =0;
    virtual int handleOutgoing() =0;
    virtual int handleTimeout() =0;
    virtual int getHandle() const =0;
};

class NetworkEventHandler : public EventHandler
{
protected:
    int handle;
    //Useful function for both Client and Server
    //getting sockaddr, IPv4 or IPv6:
    void *getInAddr(struct sockaddr *sa)
    {
        if (sa->sa_family == AF_INET)
        {
            return &(((struct sockaddr_in*)sa)->sin_addr);
        }

        return &(((struct sockaddr_in6*)sa)->sin6_addr);
    }

public:

    NetworkEventHandler(int watchedFd = 0) : handle(watchedFd) {}

    virtual ~NetworkEventHandler() {}

    virtual int handleIncoming() =0;
    virtual int handleOutgoing() =0;
    virtual int handleTimeout() =0;
    virtual int getHandle() const
    {
        return handle;
    };


    std::string getRemoteIP()
    {
        char remoteIP[INET6_ADDRSTRLEN];
        //identifying client
        struct sockaddr_storage remoteaddr; // client address
        socklen_t addrlen = sizeof remoteaddr;
        if ( 0 == getsockname(handle, (struct sockaddr*)&remoteaddr, &addrlen) )
        {
            //setting remoteIP
            inet_ntop(remoteaddr.ss_family,getInAddr((struct sockaddr*)&remoteaddr),remoteIP, INET6_ADDRSTRLEN);
        }
        else
        {
            perror(" == getRemoteIP : getsockname");
            throw std::logic_error("getRemoteIP failed !");
        }
        return remoteIP;
    }

    //return the number of byte read
    unsigned int sendRetry(std::string msg) //TODO : test on congested network
    {
        //send a message

        int msglen = msg.length();
        int nbytes = 0;

        while( nbytes < msglen ) //TODO : test by provoking network congestion.
        {
            int n = send(handle, msg.c_str() + nbytes, msglen - nbytes, 0);
            if ( n == -1)
            {
                perror(" == NetworkEventHandler : send");
                throw std::logic_error("NetworkEventHandler cannot send"); //cannot send anything
            }
            else
            {
                nbytes += n ;
            }

        }
        return nbytes;
    }

    //returns -1 on disconnection, and 0 on normal message
    // and replace msg
    int receive(std::string & msg)
    {
        //TODO : handle partial receive -> data encapsulation, etc.
        // assumption : msg always <<< 256
        char buf[256];    // buffer for data
        int nbytes;
        int res = 0;
        // handle data from endpoint
        if ((nbytes = ::recv(handle, buf, sizeof buf, 0)) <= 0)
        {
            // got error or connection closed by remote endpoint
            if (nbytes == 0)
            {
                // connection closed
                std::cout   << " == NetworkEventHandler :" << getRemoteIP() << " on socket " << handle << " has disconnected " << std::endl;
                res = -1;
            }
            else
            {
                perror(" == NetworkEventHandler : recv");
                throw std::logic_error("NetworkEventHandler cannot recv"); //cannot send anything
            }

        }
        else
        {
            msg.assign(buf);
        }
        return res;
    }


private :
    NetworkEventHandler(const NetworkEventHandler& ) {} //forbidding copy ( not sure of meaning yet )
};

// Demultiplex and dispatch Event_Handlers
// in response to client requests.
class InitDispatcher //Singleton ( only one per client or one per server )
{
    //multimap indexed by socket descriptor
    std::map<int,EventHandler*> handlers;

    //Handles
    fd_set readFds; //filedescriptor of sockets to watch for read event
    fd_set writeFds; //filedescriptor of sockets to watch for write event
    int fdmax;

    //seconds to wait before timing out
    struct timeval timeout;
    InitDispatcher(const InitDispatcher& ) {}; //forbidding copy

public :
    //private constructor for singleton
    InitDispatcher(int timeoutVal) : fdmax(0)
    {
        timeout.tv_sec = timeoutVal;
        timeout.tv_usec = 0;
    };

    ~InitDispatcher()
    {
        //cleanup ( handler destroyred by factory... )
    };

    // Entry point into the reactive event loop.
    int handleEvents() //TODO : add timeout
    {
        FD_ZERO(&readFds);
        FD_ZERO(&writeFds);


        int fdmax = 0;
        //initializing fd sets for select //remember select() will modify them
        for ( std::map<int,EventHandler*>::iterator it = handlers.begin(); it != handlers.end() ; it++)
        {
            int fd = (*it).second->getHandle(); //grabbing handler from caller again ( we could also use map keys... )
            FD_SET( fd ,&readFds);
            FD_SET( fd ,&writeFds);
            // getting maximum file descriptor number
            if ( fdmax < fd ) fdmax = fd;
        }

        //copying timeout because select will erase it
        struct timeval timer = timeout;

        //the SyncDemux from Reactor Pattern
        //using write checks as well as timeout change the timeout meaning as a socket is usually availalbe for writing -> no timeout occurs.
        //TODO : new design to handle write checks and timeouts
        int selreturn = ::select(fdmax+1, &readFds, /*&writeFds*/ NULL, NULL, &timer);
        if (selreturn == -1)
        {
            perror(" == SyncDemux : select");
            exit(4); //error on select -> throw exception, and catch it -> server should survive
        }
        else if (selreturn == 0) // timeout
        {
            //launching time out on all registered handler.
            //TODO : can we have one timeout per handler ?
            for ( std::map<int,EventHandler*>::iterator it = handlers.begin(); it != handlers.end() ; it++)
            {
                (*it).second->handleTimeout();
            }

        }
        else if (selreturn == 1) //input available
        {
            // run through the existing connections looking for data to read
            for ( std::map<int,EventHandler*>::iterator it = handlers.begin(); it != handlers.end() ; it++)
            {
                //TODO : launch in separate threads to keep waiting while handler are running.
                // and check Proactor
                if (FD_ISSET((*it).first, &readFds))
                {
                    // we got one
                    (*it).second->handleIncoming();
                }
                //if (FD_ISSET((*it).first, &writeFds))
                //{ // we got new data to write
                //    (*it).second->handleOutgoing();
                //}
            } // END looping through file descriptors

        }
        return 0;
    }
    int registerHandler( EventHandler * eh )
    {
        //grabbing handle ( socket_fd )
        int fd = eh->getHandle();

        //TODO : check return to ensure we dont try to add more than one handler per socket
        handlers.insert( std::pair<int,EventHandler*>(fd,eh));

        if ( fd > fdmax ) fdmax = fd; //keeping track of the max

        //returning the handle registered
        return fd;
    }
    int removeHandler( EventHandler * eh)
    {
        //grabbing handle ( socket_fd )
        int fd = eh->getHandle();

        FD_CLR(fd ,&writeFds);
        // decreasing the max until we reach a fd ( int ) present in the set
        if ( fd == fdmax ) while ( ! FD_ISSET(fdmax, &writeFds) && --fdmax) ; //will stop at fdmax == 0 or when new max found in set
        FD_CLR(fd ,&readFds);
        // decreasing the max until we reach a fd ( int ) present in the set
        if ( fd == fdmax ) while ( ! FD_ISSET(fdmax, &readFds) && --fdmax) ; //will stop at fdmax == 0 or when new max found in set

        handlers.erase( fd ); //erase in map

        //returning the handle
        return fd;
    }
    std::map<int,EventHandler*>* getHandlerMap()
    {
        return & handlers;
    }


};

//To isolate code. Will use either Server or Client.
//They can both use the singleton InitDisp, since it s two different runs.
class Server : public NetworkEventHandler
{
    //TODO : implementing EventHandlers with hte command design patterns seems to make sense
    class DataHandler : public NetworkEventHandler
    {
        Server* master;
    public:
        DataHandler(int watchedFd,Server * serv): NetworkEventHandler ( watchedFd ), master(serv)
        {
            std::string remoteIP = getRemoteIP();

            //send a welcome message
            std::string msg = ("CONNOK");
            unsigned int nbytes = sendRetry(msg);

            if (nbytes == msg.length()) // ok message transmitted
            {
                std::cout   << " == DataHandler : Welcome message successfully sent to " << remoteIP << " on socket " << handle << std::endl;
            }
            else
            {
                //cancelling construction by throwing exception
                throw std::logic_error("DataHandler : unable to send message on socket handle");
            }
        }

        virtual ~DataHandler()
        {
            close(handle); // bye!
        }

        virtual int handleIncoming()
        {
            //Socket ready for reading
            std::string remoteIP = getRemoteIP();

            std::string rmsg;
            int res = receive(rmsg);
            if ( res == -1 )
            {
                // connection closed
                std::cout   << " == DataHandler : End of transmission from " << remoteIP << " on socket " << handle << std::endl;
                //delayed suicide
                master->destroyHandler(this,true);
            }
            else if ( res ==0 )
            {
                //success
                std::cout << " == DataHandler : New message from " << remoteIP << " on socket " << handle << std::endl;
                std::cout << rmsg << std::endl;

                if ( rmsg == "LOGOUT")
                {
                    std::string msg("CONNEND");
                    unsigned int numsend = sendRetry(msg);
                    if ( numsend  != msg.length())
                    {
                        std::cout << " == DataHandler : sending CONNEND message to " << remoteIP << " on socket " << handle << " FAILED !" << std::endl;
                    }
                    else
                    {
                        std::cout << " == DataHandler : sending CONNEND message to " << remoteIP << " on socket " << handle << " SUCCESS !" << std::endl;
                    }

                }
            }
            return 0;
        }
        virtual int handleOutgoing()
        {
            //Socket ready for writing

            //TODO
            return 0;
        }
        virtual int handleTimeout()
        {
            //Socket has timedout
            //doing nothing on datahandler ( client socket )
            return 0;
        }

    private :
        DataHandler(const DataHandler&) {} //forbidding copies for now, not sure about meaning...
    };

    ///TODO : Server should act as a factory for event handler ( including data handler )
    /// -> server neds to be notified when a data handler is not useful anymore, and destroy it

    unsigned int maxClients;

    InitDispatcher * dispatcher;

    //keeping a list of event handler to garbage collect when not needed anymore
    std::vector<EventHandler*> toDestroy;

public :
    /**default Server constructor
     * @param port is a string containing the number of the port to open a socket on. for exemple "1234"
     * @param maxConnect is the maximum number of client allowed
     */
    Server( std::string port = "1234", int maxConnect = 10 ) : NetworkEventHandler(), maxClients(maxConnect)
    {

        int yes=1; // for setsockopt() SO_REUSEADDR, below
        int rv;

        struct addrinfo hints, *ai, *p;
        char s[INET6_ADDRSTRLEN];

        // get us a socket and bind it
        memset(&hints, 0, sizeof hints);
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = AI_PASSIVE;
        if ((rv = getaddrinfo(NULL, port.c_str(), &hints, &ai)) != 0)
        {
            fprintf(stderr, "Server: %s\n", gai_strerror(rv));
            exit(1);
        }


        for(p = ai; p != NULL; p = p->ai_next)
        {
            handle = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
            if (handle < 0)
            {
                continue;
            }

            //authorize immediate reuse of socket
            setsockopt(handle, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int));

            if (bind(handle, p->ai_addr, p->ai_addrlen) < 0)
            {
                close(handle);
                continue;
            }

            break;
        }

        if (p == NULL)
        {
            fprintf(stderr, "Server::Server(): failed to bind\n");
            exit(2); //TODO exception -> not constructed
        }

        inet_ntop(p->ai_family, getInAddr((struct sockaddr *)p->ai_addr),
                  s, sizeof s);

        freeaddrinfo(ai); // all done with this

        dispatcher = new InitDispatcher(1);
        dispatcher->registerHandler(this);

        std::cout << " == Server : Initialized on " << s << ":" << port << std::endl;
    }

    int waitAndReact()
    {
        if (::listen(handle, BACKLOG) == -1)
        {
            perror("listen");
            exit(1);
        }
        std::cout << " == Server : Waiting for connections..." << std::endl;
        for (;;)
        {
            dispatcher->handleEvents();
        }
        //not reached
        return 0;
    }

    //creating DataHandler from socket filedescriptor
    virtual EventHandler* createHandler(int newfd)
    {
        EventHandler * eh = new DataHandler(newfd,this);
        dispatcher->registerHandler(eh); //dispatcher will manage it
        return eh; //useful in cas eof factory only
    }

    //destroying Handler ( socket fd is closed -> not returning it )
    virtual void destroyHandler( EventHandler* dh, bool delay = false)
    {
        dispatcher->removeHandler(dh);
        if (delay)
        {
            toDestroy.push_back(dh);
            //delayed destruction
        }
        else
        {
            //immediate destruction
            delete dh, dh=0;
        }
    }

    virtual int handleIncoming()
    {
        char remoteIP[INET6_ADDRSTRLEN];

        // handle new connections
        struct sockaddr_storage remoteaddr; // client address
        socklen_t addrlen = sizeof remoteaddr;
        int newfd = accept(handle, (struct sockaddr *)&remoteaddr, &addrlen);
        if (newfd == -1)
        {
            perror(" == Server : accept");
        }
        else
        {
            //if not overloaded
            if ( dispatcher->getHandlerMap()->size()-1 < maxClients )
            {
                //create and register new handler
                createHandler(newfd);

                std::cout   << " == Server : New connection from "
                            << inet_ntop(remoteaddr.ss_family,getInAddr((struct sockaddr*)&remoteaddr),remoteIP, INET6_ADDRSTRLEN)
                            << " on socket "
                            << newfd
                            << std::endl;
            }
            else
            {
                std::cout   << " == Server : OVERLOAD : New connection from "
                            << inet_ntop(remoteaddr.ss_family,getInAddr((struct sockaddr*)&remoteaddr),remoteIP, INET6_ADDRSTRLEN)
                            << " REFUSED "
                            << std::endl;
            }
        }
        return 0;
    }
    virtual int handleOutgoing()
    {
        //Socket ready for writing
        //this is a listening socket -> shouldnt be called
        std::cerr << "ERROR : Listening socket available for writing ?!?!" << std::endl;
        //TODO
        return 0;
    }
    virtual int handleTimeout()
    {
        //Socket has timedout

        //garbage collecting unused handler
        toDestroy.clear();

        //not nice, but works. Proper way would be to define interface in init dispatcher to retrieve IP list
        std::map<int,EventHandler*> dHandler = *(dispatcher->getHandlerMap());

        std::cout  << " == Server : " << dHandler.size()-1 << " Current Connections : "  << std::endl;

        //display number of connected client + IP addresses

        for ( std::map<int,EventHandler*>::iterator it = dHandler.begin(); it != dHandler.end() ; it++)
        {
            if ((*it).first != handle)
            {
                //All event handlers are network event handlers here
                std::string rip = (dynamic_cast<NetworkEventHandler*>((*it).second))->getRemoteIP();
                std::cout << " ==== " << rip << std::endl;
            }
        }
        return 0;
    }

    virtual ~Server()
    {
        dispatcher->removeHandler(this);
        close(handle);

        //not nice, but works. Proper way would be to have initdispatcher being owner of event handlers... -> review design TODO
        std::map<int,EventHandler*> dHandler = *(dispatcher->getHandlerMap());

        //delete all handlers
        for ( std::map<int,EventHandler*>::iterator it = dHandler.begin(); it != dHandler.end() ; it++)
        {
            //removing it from dispatcher just in case
            dispatcher->removeHandler((*it).second);
            delete (*it).second, (*it).second = 0; //deleting handler will close socket
        }

        delete dispatcher, dispatcher =0;
    }



private :
    Server(const Server &) //forbidding copies
    {
    }

};

class Client : public NetworkEventHandler
{
    bool exiting;

    InitDispatcher* dispatcher;

public:

    Client( std::string hostname, std::string port) :  NetworkEventHandler(), exiting(false)
    {
        struct addrinfo hints, *servinfo, *p;
        int rv;
        char s[INET6_ADDRSTRLEN];

        memset(&hints, 0, sizeof hints);
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;

        if ((rv = getaddrinfo(hostname.c_str(), port.c_str(), &hints, &servinfo)) != 0)
        {
            fprintf(stderr, " == Client : getaddrinfo: %s\n", gai_strerror(rv));
            throw std::runtime_error("Client cannot be created. getaddrinfo failed.");
        }

        // loop through all the results and connect to the first we can
        for(p = servinfo; p != NULL; p = p->ai_next)
        {
            if ((handle = socket(p->ai_family, p->ai_socktype,
                                 p->ai_protocol)) == -1)
            {
                perror(" == Client : socket");
                continue;
            }

            if (::connect(handle, p->ai_addr, p->ai_addrlen) == -1)
            {
                close(handle);
                perror(" == Client : connect");
                continue;
            }

            break;
        }

        if (p == NULL)
        {
            fprintf(stderr, "client: failed to connect\n");
            throw std::runtime_error("Client cannot establish connection.");
        }

        inet_ntop(p->ai_family, getInAddr((struct sockaddr *)p->ai_addr), s, sizeof s);
        std::cout << " == Client : Connecting to " << s << ":" << port << std::endl ;

        freeaddrinfo(servinfo); // all done with this structure

        dispatcher = new InitDispatcher(3);
        dispatcher->registerHandler(this);
    }
    virtual int handleIncoming()
    {
        //Socket ready for reading
        std::string remoteIP = getRemoteIP();

        std::string rmsg;
        int res = receive(rmsg);

        if ( res == -1)
        {
            //disconnection
            std::cout   << " == Client : Server down at " << remoteIP << " on socket " << handle << std::endl;
            exiting = true;

        }
        else if (res ==0 )
        {

            std::cout << " == Client : New message from " << remoteIP << " on socket " << handle << std::endl;
            std::cout << rmsg << std::endl;

            if ( rmsg == "CONNEND") exiting=true;
        }
        return 0;
    }
    virtual int handleOutgoing()
    {
        //Socket ready for writing

        //TODO
        return 0;
    }
    virtual int handleTimeout()
    {
        std::string remoteIP = getRemoteIP();

        std::string msg = ("LOGOUT");
        unsigned int nbytes = sendRetry(msg);

        //check just in case...
        if (nbytes == msg.length()) // ok message transmitted
        {
            std::cout   << " == DataHandler : Logout message successfully sent to " << remoteIP << " on socket " << handle << std::endl;
        }

        return 0;
    }


    int waitAndReact()
    {
        while ( ! exiting )
        {
            dispatcher->handleEvents();
        }

        return 0;
    }

    virtual ~Client()
    {
        close(handle);
    }

private:
    Client( const Client &) //forbidding copy for now ( meaning ??? )
    {

    }

};



using namespace std;
//TODO : cathing SIGINT and others, to gracefully cleanup and shutdown
int main(int argc, char* argv[])
{
    if ( argc == 3 ) //client with ip  and port to connect to
    {
        Client* client_instance = new Client(argv[1],argv[2]);
        //TODO : arg checks
        client_instance->waitAndReact();
        //not needed anymore
        delete client_instance, client_instance =0;
    }
    else if( argc == 2) //server with port to open socket on
    {
        Server* serv_instance =  new Server(argv[1]);
        //TODO : arg checks
        serv_instance->waitAndReact();
        //not needed anymore
        delete serv_instance, serv_instance =0;
    }
    else if( argc == 1) //default port for server
    {
        Server* serv_instance =  new Server();
        //TODO : arg checks
        serv_instance->waitAndReact();
        //not needed anymore
        delete serv_instance, serv_instance =0;
    }
    else
    {
        std::cout << "Server Usage: " << argv[0] << " [ <port_number> ]" << std::endl;
        std::cout << "Client Usage: " << argv[0] << " <server_ip> <port_number>" << std::endl;
        return 1;
    }

    return 0;
}
