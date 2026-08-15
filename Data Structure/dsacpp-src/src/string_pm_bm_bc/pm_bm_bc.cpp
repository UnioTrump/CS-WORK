/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

/*DSA*/#include "string_pm/string_pm_test.h"

int match( char* P, char* T ) { //Boyer-Morre算法（简化版，只考虑Bad Character Shift）
   int* bc = buildBC( P ); //预处理
   int n = strlen( T ), i; //文本串长度、与模式串首字符的对齐位置
   int m = strlen( P ), j; //模式串长度、模式串当前字符位置
   for ( i = 0; i+m <= n; i += max(1, j - bc[ T[i+j] ]) ) { //不断右移P
      for ( j = m-1; (0 <= j) && (P[j] == T[i+j]); j-- ); //自右向左逐个比对
      /*DSA*/showProgress ( T, P, i, j );
      if ( j < 0 ) break; //一旦完全匹配，随即收工
   }
   delete [] bc; return i; //销毁BC表，返回最终的对齐位置
}