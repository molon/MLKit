//
//  MLThread.h
//  MLKitExample
//
//  Created by molon on 16/7/12.
//  Copyright © 2016年 molon. All rights reserved.
//
#pragma once

#import <assert.h>
#import <pthread.h>
#import <stdbool.h>
#import <stdlib.h>

#import <libkern/OSAtomic.h>

#import "MLKitMacro.h"

static inline bool dispatch_is_main_queue() {
    return pthread_main_np() != 0;
}

static inline void dispatch_force_async_on_main_queue(void (^block)()) {
    dispatch_async(dispatch_get_main_queue(), block);
}

static inline void dispatch_async_on_global_queue(void (^block)()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

/*
 Copy from AsyncDisplayKit below
 */

#if defined (__cplusplus) && defined (__GNUC__)
# define MLTHREAD_NOTHROW __attribute__ ((nothrow))
#else
# define MLTHREAD_NOTHROW
#endif

/**
 Only .mm file can use MLDN below
 */
#ifdef __cplusplus

/**
 For use with MLDN::StaticMutex only.
 */
#define MLTHREAD_MUTEX_INITIALIZER {PTHREAD_MUTEX_INITIALIZER}
#define MLTHREAD_MUTEX_RECURSIVE_INITIALIZER {PTHREAD_RECURSIVE_MUTEX_INITIALIZER}

// This MUST always execute, even when assertions are disabled. Otherwise all lock operations become no-ops!
// (To be explicit, do not turn this into an NSAssert, assert(), or any other kind of statement where the
// evaluation of x_ can be compiled out.)
#define MLTHREAD_THREAD_ASSERT_ON_ERROR(x_) do { \
_Pragma("clang diagnostic push"); \
_Pragma("clang diagnostic ignored \"-Wunused-variable\""); \
volatile int res = (x_); \
assert(res == 0); \
_Pragma("clang diagnostic pop"); \
} while (0)

namespace MLDN {
    
    template<class T>
    class Locker
    {
        T &_l;
        
    public:
        Locker (T &l) MLTHREAD_NOTHROW : _l (l) {
            _l.lock ();
        }
        
        ~Locker () {
            _l.unlock ();
        }
        
        // non-copyable.
        Locker(const Locker<T>&) = delete;
        Locker &operator=(const Locker<T>&) = delete;
    };
    
    
    template<class T>
    class Unlocker
    {
        T &_l;
    public:
        Unlocker (T &l) MLTHREAD_NOTHROW : _l (l) {_l.unlock ();}
        ~Unlocker () {_l.lock ();}
        Unlocker(Unlocker<T>&) = delete;
        Unlocker &operator=(Unlocker<T>&) = delete;
    };
    
    struct Mutex
    {
        /// Constructs a non-recursive mutex (the default).
        Mutex () : Mutex (false) {}
        
        ~Mutex () {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_mutex_destroy (&_m));
        }
        
        Mutex (const Mutex&) = delete;
        Mutex &operator=(const Mutex&) = delete;
        
        void lock () {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_mutex_lock (this->mutex()));
        }
        
        void unlock () {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_mutex_unlock (this->mutex()));
        }
        
        pthread_mutex_t *mutex () { return &_m; }
        
    protected:
        explicit Mutex (bool recursive) {
            if (!recursive) {
                MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_mutex_init (&_m, NULL));
            } else {
                pthread_mutexattr_t attr;
                MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_mutexattr_init (&attr));
                MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
                MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_mutex_init (&_m, &attr));
                MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_mutexattr_destroy (&attr));
            }
        }
        
    private:
        pthread_mutex_t _m;
    };
    
    /**
     Obj-C doesn't allow you to pass parameters to C++ ivar constructors.
     Provide a convenience to change the default from non-recursive to recursive.
     
     But wait! Recursive mutexes are a bad idea. Think twice before using one:
     
     http://www.zaval.org/resources/library/butenhof1.html
     http://www.fieryrobot.com/blog/2008/10/14/recursive-locks-will-kill-you/
     */
    struct RecursiveMutex : Mutex
    {
        RecursiveMutex () : Mutex (true) {}
    };
    
    typedef Locker<Mutex> MutexLocker;
    typedef Unlocker<Mutex> MutexUnlocker;
    
    /**
     If you are creating a static mutex, use StaticMutex and specify its default value as one of MLTHREAD_MUTEX_INITIALIZER
     or MLTHREAD_MUTEX_RECURSIVE_INITIALIZER. This avoids expensive constructor overhead at startup (or worse, ordering
     issues between different static objects). It also avoids running a destructor on app exit time (needless expense).
     
     Note that you can, but should not, use StaticMutex for non-static objects. It will leak its mutex on destruction,
     so avoid that!
     
     If you fail to specify a default value (like MLTHREAD_MUTEX_INITIALIZER) an assert will be thrown when you attempt to lock.
     */
    struct StaticMutex
    {
        pthread_mutex_t _m; // public so it can be provided by MLTHREAD_MUTEX_INITIALIZER and friends
        
        void lock () {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_mutex_lock (this->mutex()));
        }
        
        void unlock () {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_mutex_unlock (this->mutex()));
        }
        
        pthread_mutex_t *mutex () { return &_m; }
        
        StaticMutex(const StaticMutex&) = delete;
        StaticMutex &operator=(const StaticMutex&) = delete;
    };
    
    typedef Locker<StaticMutex> StaticMutexLocker;
    typedef Unlocker<StaticMutex> StaticMutexUnlocker;
    
    struct Condition
    {
        Condition () {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_cond_init(&_c, NULL));
        }
        
        ~Condition () {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_cond_destroy(&_c));
        }
        
        // non-copyable.
        Condition(const Condition&) = delete;
        Condition &operator=(const Condition&) = delete;
        
        void signal() {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_cond_signal(&_c));
        }
        
        void wait(Mutex &m) {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_cond_wait(&_c, m.mutex()));
        }
        
        pthread_cond_t *condition () {
            return &_c;
        }
        
    private:
        pthread_cond_t _c;
    };
    
    struct ReadWriteLock
    {
        ReadWriteLock() {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_rwlock_init(&_rwlock, NULL));
        }
        
        ~ReadWriteLock() {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_rwlock_destroy(&_rwlock));
        }
        
        // non-copyable.
        ReadWriteLock(const ReadWriteLock&) = delete;
        ReadWriteLock &operator=(const ReadWriteLock&) = delete;
        
        void readlock() {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_rwlock_rdlock(&_rwlock));
        }
        
        void writelock() {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_rwlock_wrlock(&_rwlock));
        }
        
        void unlock() {
            MLTHREAD_THREAD_ASSERT_ON_ERROR(pthread_rwlock_unlock(&_rwlock));
        }
        
    private:
        pthread_rwlock_t _rwlock;
    };
    
    class ReadWriteLockReadLocker
    {
        ReadWriteLock &_lock;	
    public:
        ReadWriteLockReadLocker(ReadWriteLock &lock) MLTHREAD_NOTHROW : _lock(lock) {
            _lock.readlock();
        }
        
        ~ReadWriteLockReadLocker() {
            _lock.unlock();
        }
        
        // non-copyable.
        ReadWriteLockReadLocker(const ReadWriteLockReadLocker&) = delete;
        ReadWriteLockReadLocker &operator=(const ReadWriteLockReadLocker&) = delete;
    };
    
    class ReadWriteLockWriteLocker
    {
        ReadWriteLock &_lock;
    public:
        ReadWriteLockWriteLocker(ReadWriteLock &lock) MLTHREAD_NOTHROW : _lock(lock) {
            _lock.writelock();
        }
        
        ~ReadWriteLockWriteLocker() {
            _lock.unlock();
        }
        
        // non-copyable.
        ReadWriteLockWriteLocker(const ReadWriteLockWriteLocker&) = delete;
        ReadWriteLockWriteLocker &operator=(const ReadWriteLockWriteLocker&) = delete;
    };
    
} // namespace mlDN

#endif /* __cplusplus */
