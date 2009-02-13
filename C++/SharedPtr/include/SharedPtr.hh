//
// C++ Interface: SharedPtr
//
// Description: Implements a Shared Pointer class. deletes the object to which it refers when the last SharedPtr that refers it is destroyed.
//
//
// Author:  <alex@asmodehn.net>, (C) 2009
//
// Copyright: See COPYING file that comes with this distribution
//
//

#ifndef SHAREDPTR_HH
#define SHAREDPTR_HH

template <class T>
class SharedPtr{
	private:
		T* ptr;				//pointer to the value
		long* count;		//shared number of owners
	public:
		//initialize pointer with existing pointer
		// - requires that the pointer p is a return value of new
		explicit SharedPtr (T* p=0)
		 : ptr(p), count(new long(1))
		{}
		
		//copy pointer ( one more owner )
		SharedPtr ( const SharedPtr<T>& p ) throw()
		 : ptr(p.ptr), count(p.count)
		{
			++*count;
		}
		
		//destructor ( delete value if this was hte last owner
		~SharedPtr () throw ()
		{
			dispose();
		}
		
		//assignement ( unshare old and share new value )
		SharedPtr<T>& operator= ( const SharedPtr<T>& p ) throw ()
		{
			if ( this != &p)
			{
				dispose();
				ptr = p.ptr;
				count = p.count;
				++*count;
			}
			return *this;
		}
		
		//access hte value to which the pointer refers
		T& operator*() const throw()
		{
			return *ptr;
		}
		T* operator->() const throw()
		{
			return ptr;
		}
		
		private:
		void dispose()
		{
			if (--*count == 0)
			{
				delete count;
				delete ptr;
			}
		}
	};

#endif