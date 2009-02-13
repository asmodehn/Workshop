#ifndef SDLMONITORDATA_HH
#define SDLMONITORDATA_HH

#include "System/SDLScopedLock.hh"
#include "System/SDLCondition.hh"

#include <map>
#include <vector>

namespace RAGE
{
    namespace SDL
    {

		
        /**
        * \class MonitorMap
        *
        * \ingroup System
        *
        * \brief This class is a thread safe wrapper for STL map, using the default allocator ( protected by mutex )
		*
        *
        * \author Alex
        *
        * \date 2009/02/12
        *
        * Contact: asmodehn@gna.org
        *
        */

		template <typename DataT>
			typedef Reference DataT&; //allocator<T>::reference

		template <typename DataT>
			typedef ConstReference const DataT&; //allocator<T>::const_reference

		/*
		template <typename DataT>
			typedef Pointer DataT*; //allocator<T>::pointer

		template <typename DataT>
			//which one is true ????
			typedef ConstPointer const DataT* ; //allocator<T>::const_pointer
			typedef ConstPointer DataT* const; //allocator<T>::const_pointer
		*/

//iterator	Random access iterator
//const_iterator	Constant random access iterator
//size_type	Unsigned integral type (usually same as size_t)
//difference_type	Signed integral type (usually same as ptrdiff_t)
//value_type	T
//allocator_type	Allocator
//reverse_iterator	reverse_iterator<iterator>
//const_reverse_iterator	reverse_iterator<const_iterator>


		//TODO : implement public interface
		//TODO : prevent copy ( can bypass threads locks )

		template <typename KeyT,typename DataT>
		class MonitorMap
		{
		private:
			std::map<KeyT,DataT> m_map;

			Mutex m_monitorMtx;
			Condition m_itemAvailable;

		public: 



		};















//==============================================================================================

	   /**
        * \class MonitorVector
        *
        * \ingroup System
        *
        * \brief This class is a thread safe wrapper for STL vector
        *
        * \author Alex
        *
        * \date 2009/02/12
        *
        * Contact: asmodehn@gna.org
        *
        */

		template <typename DataT>
		class MonitorVector
		{
		private:
			std::vector<DataT> m_map;

			Mutex m_monitorMtx;
			Condition m_itemAvailable;

		public:
		
			//Default constructor: constructs an empty vector, with no content and a size of zero.
			MonitorVector();

			//Repetitive sequence constructor: Initializes the vector with its content set to a repetition, n times, of copies of value.
			MonitorVector(size_type n, const DataT& value= DataT());

			//Iteration constructor: Iterates between first and last, setting a copy of each of the sequence of elements as the content of the container.
			template <class InputIterator>
				MonitorVector ( InputIterator first, InputIterator last);

			//Copy constructor: The vector is initialized to have the same contents (copies) and properties as vector x.
			MonitorVector ( const MonitorVector<DataT>& x );

			//Destructs the container object. This calls each of the contained element's destructors, and deallocates all the storage capacity allocated by the vector.
			~MonitorVector();

			//Copy vector content
			//Assigns a copy of vector x as the new content for the vector object.
			//The elements contained in the vector object before the call are dropped, and replaced by copies of those in vector x, if any.
			//After a call to this member function, both the vector object and vector x will have the same size and compare equal to each other.
			MonitorVector<DataT>& operator= (const MonitorVector<DataT>& x);

			//Return iterator to beginning
			//Returns an iterator referring to the first element in the vector container.
			//Notice that unlike member vector::front, which returns a reference to the first element, this function returns a random access iterator.
			Iterator begin ();
			ConstIterator begin () const;


			//Return iterator to end
			//Returns an iterator referring to the past-the-end element in the vector container.
			//Notice that unlike member vector::back, which returns a reference to the element preceding this one, this function returns a random access iterator.
		    Iterator end ();
			ConstIterator end () const;

			//Return reverse iterator to reverse beginning
			//Returns a reverse iterator referring to the last element in the vector container.
			//rbegin refers to the element right before the one that would be referred to by member end.
			//Notice that unlike member vector::back, which returns a reference to this same element, this function returns a reverse random access iterator.
			ReverseIterator rbegin();
			ConstReverseIterator rbegin() const;

			//Return reverse iterator to reverse end
			//Returns a reverse iterator referring to the element right before the first element in the vector, which is considered its reverse end.
			//rend refers to the character right before the one that would be referred to by member begin.
			ReverseIterator rend();
			ConstReverseIterator rend() const;

			//Return size
			//Returns the number of elements in the vector container.
			//This is the number of actual objects held in the vector, which is not necessarily equal to its storage capacity. Vectors automatically reallocate their storage space when needed or when requested with member resize. To retrieve the current storage capacity of a vector you can call to its member capacity.
			size_type size() const;

			//Return maximum size
			//Returns the maximum number of elements that the vector container can hold.
			//This is not the amount of storage space currently allocated to the vector (this can be obtained with member vector::capacity), but the maximum potential size the vector could reach due to system or library implementation limitations.
			size_type max_size () const;
			
			//Change size
			//Resizes the vector to contain sz elements.
			//If sz is smaller than the current vector size, the content is reduced to its first sz elements, the rest being dropped.
			//If sz is greater than the current vector size, the content is expanded by inserting at the end as many copies of c as needed to reach a size of sz elements. This may cause a reallocation.
			//Notice that this function changes the actual content of the vector by inserting or erasing elements from the vector; It does not only change its storage capacity. To direct a change only in storage capacity, use vector::reserve instead.
			void resize ( size_type sz, DataT c = DataT() );

			//Return size of allocated storage capacity
			//Returns the size of the allocated storage space for the elements of the vector container.
			//Notice that, in vectors, the capacity is not necessarily equal to the number of elements that conform the underlying vector content (this can be obtained with member vector::size), but the capacity of the actual allocated space, which is either equal or greater than the content size.
			//Notice also that this capacity does not suppose a limit to the size of the vector. If more space is required to accomodate new elements in the vector, the capacity is automatically expanded, or can even be explicitly modified by calling member vector::reserve.
			//The real limit on the size a vector object can reach is returned by member vector::max_size.
			size_type capacity () const;

			//Test whether vector is empty
			//Returns whether the vector container is empty, i.e. whether its size is 0.
			//This function does not modify the content of the vector in any way. To clear the content of a vector, use vector::clear.
			bool empty () const;

			//Request a change in capacity
			//Requests that the capacity of the allocated storage space for the elements of the vector container be at least enough to hold n elements.
			//This informs the vector of a planned increase in size, although notice that the parameter n informs of a minimum, so the resulting capacity may be any capacity equal or larger than this.
			//When n is greater than the current capacity, a reallocation is attempted during the call to this function. If successful, it grants that no further automatic reallocations will happen because of a call to vector::insert or vector::push_back until the vector size surpasses at least n (this preserves the validity of iterators on all these future calls).
			//A reallocation invalidates all previously obtained iterators, references and pointers to elements of the vector.
			//In any case, a call to this function never affects the elements contained in the vector, nor the vector size (for that purposes, see vector::resize or vector::erase, which modify the vector size and content).
			void reserve ( size_type n );

			//Access element
			//Returns a reference to the element at position n in the vector container.
			//A similar member function, vector::at, has the same behavior as this operator function, except that vector::at signals if the requested position is out of range by throwing an exception.
			Reference operator[] ( size_type n );
			ConstReference operator[] ( size_type n ) const;

			//Access element
			//Returns a reference to the element at position n in the vector.
			//The difference between this member function and member operator function operator[] is that vector::at signals if the requested position is out of range by throwing an out_of_range exception.	
			ConstReference at ( size_type n ) const;
			Reference at ( size_type n );

			//Access first element
			//Returns a reference to the first element in the vector container.
			//Unlike member vector::begin, which returns an iterator to this same element, this function returns a direct reference.	
			Reference front ( );
			ConstReference front ( ) const;

			//Access last element
			//Returns a reference to the last element in the vector container.
			//Unlike member vector::end, which returns an iterator just past this element, this function returns a direct reference.
			Reference back ( );
			ConstReference back ( ) const;

			//Assign vector content
			//Assigns new content to the vector object, dropping all the elements contained in the vector before the call and replacing them by those specified by the parameters:
			//In the first version (with iterators), the new contents are a copy of the elements in the sequence between first and last (in the range [first,last)).
			//In the second version, the new content is the repetition n times of copies of element u.
			template <class InputIterator>
				void assign ( InputIterator first, InputIterator last );
			void assign ( size_type n, const DataT& u );

			//Add element at the end
			//Adds a new element at the end of the vector, after its current last element. The content of this new element is initialized to a copy of x.
			//This effectively increases the vector size by one, which causes a reallocation of the internal allocated storage if the vector size was equal to the vector capacity before the call. Reallocations invalidate all previously obtained iterators, references and pointers.	
			void push_back ( const DataT& x );

			//Delete last element
			//Removes the last element in the vector, effectively reducing the vector size by one and invalidating all iterators and references to it.
			//This calls the removed element's destructor.
			void pop_back ( );

			//Insert elements
			//The vector is extended by inserting new elements before the element at position.
			//This effectively increases the vector size, which causes an automatic reallocation of the allocated storage space if, and only if, the new vector size surpases the current vector capacity. Reallocations in vector containers invalidate all previously obtained iterators, references and pointers.
			//Because vectors keep an array format, insertions on positions other than the vector end are performed by moving all the elements between position and the end of the vector to their new positions, and then inserting the new element(s), which may not be a method as efficient as the insertion in other kinds of sequence containers (deque, list).
			//The parameters determine how many elements are inserted and to which values they are initialized
			Iterator insert ( Iterator position, const T& x );
		    void insert ( Iterator position, size_type n, const T& x );
			template <class InputIterator>
				void insert ( Iterator position, InputIterator first, InputIterator last );

	
			//Erase elements
			//Removes from the vector container either a single element (position) or a range of elements ([first,last)).
			//This effectively reduces the vector size by the number of elements removed, calling each element's destructor before.
			//Because vectors keep an array format, erasing on positions other than the vector end also moves all the elements after the segment erased to their new positions, which may not be a method as efficient as erasing in other kinds of sequence containers (deque, list).
			//This invalidates all iterator and references to elements after position or first.
			Iterator erase ( Iterator position );
			Iterator erase ( Iterator first, Iterator last );

			
			//Swap content
			//Exchanges the content of the vector by the content of vec, which is another vector of the same type. Sizes may differ.
			//After the call to this member function, the elements in this container are those which were in vec before the call, and the elements of vec are those which were in this. All iterators, references and pointers remain valid for the swapped vectors.
			//Notice that a global algorithm function exists with this same name, swap, and the same behavior.
			void swap ( MonitorVector<DataT>& vec );

			//Clear content
			//All the elements of the vector are dropped: their destructors are called, and then they are removed from the vector container, leaving the container with a size of 0.
			void clear ( );

			//Get allocator
			//Returns the allocator object used to constuct the vector.
			AllocatorType get_allocator() const;

	
	


/*
Vector specialization: vector<bool>
The vector class template has a special template specialization for the bool type.

This specialization is provided to optimize for space allocation: In this template specialization, each element occupies only one bit (which is eight times less than the smallest type in C++: char).

The references to elements of a bool vector returned by the vector members are not references to bool objects, but a special member type which is a reference to a single bit, defined inside the vector<bool> class specialization as:

class vector<bool>::reference {
  friend class vector;
  reference();                                 // no public constructor
public:
  ~reference();
  operator bool () const;                      // convert to bool
  reference& operator= ( const bool x );       // assign from bool
  reference& operator= ( const reference& x );  // assign from bit
  void flip();                                 // flip bit value.
}

*/	





	


		};

	} //SDL
} // RAGE

#endif