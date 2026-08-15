/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <ctime>
#include "_share/util.h"
#include "UniPrint/print.h"
#include "vector/vector.h"
#include "factorial/fac.h"

__int64 passed = 0;
__int64 done = 0;
__int64 all = 0;

/******************************************************************************************
 * 排序算法完全测试
 ******************************************************************************************/
int test( Vector<Rank>& A, Rank n ) {
   if ( n < 2 ) {
      Vector<Rank> X(A); //print(X);
      X.sort(); //print(X); printf("\n");
      for ( Rank i = 0; i < X.size(); i++ )
         if ( X[i] != i/2 ) { print(X); return 1; }
      passed++;
      if ( ( (passed - done) > 999999 ) || ( (passed - done)*20 > all ) )
         { printf( "%.1f%% : %I64d / %I64d\n", 100.*passed/all, passed, all ); done = passed; }
      return 0;
   }
   for ( Rank i = 0; i < n; i++ ) {
      if ( test( A, n-1 ) ) return 1;
      swap( A[n % 2 ? 0 : i], A[n-1] );
   }
   return 0;
}

int sorterTest( Rank n ) {
   Vector<Rank> A(n);
   for ( Rank i = 0; i < n; i++ ) A.insert( i/2 ); print( A );
   return test( A, n );
}

int main( int argc, char* argv[] ) {
   if ( 2 > argc ) { printf( "Usage:\n\t%s <sequence length> \a\a\n", argv[0] ); return 1; }
   srand( (unsigned int)time( NULL ) ); //随机种子
   //srand( 31415926 ); //固定种子（假种子，调试用）
   int tests = abs( atoi( argv[1] ) );
   printf( "test length = %d\n", tests );
   all = facI( tests );
   sorterTest( tests ); printf( "%I64d / %I64d passed\n", passed, all );
   return 0;
}
