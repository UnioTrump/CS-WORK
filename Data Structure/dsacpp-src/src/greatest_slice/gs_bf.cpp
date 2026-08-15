/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#include "sum/sum.h"
extern int s_lo, s_hi;

int gs_BF( int A[], int n ) { //蛮力策略：O(n^3)
   int gs = A[0]; s_lo = 0; s_hi = 1;
   for ( int lo = 0; lo < n; lo++ ) //枚举所有的
      for ( int hi = lo; hi < n; ) { //O(n^2)个区段
         int s = sum(A, lo, ++hi); //用O(n)时间求和（改用sum(A+lo,++hi-lo)空间效率更高）
         if ( gs < s )
            { gs = s; s_lo = lo; s_hi = hi; } //择优、更新
      }
   return gs;
}
