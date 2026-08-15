/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#pragma once

/******************************************************************************************
 * RedBlack双红调整算法：解决节点x与其父均为红色的问题。分为两大类情况：
 *    RR-1：2次颜色翻转，2次黑高度更新，1~2次旋转，不再递归
 *    RR-2：3次颜色翻转，3次黑高度更新，0次旋转，需要递归
 ******************************************************************************************/
template <typename T> void RedBlack<T>::solveDoubleRed( BinNodePosi<T> x ) { //x当前必为红
   while ( 1 ) {
      if ( !x->parent ) //若已（递归）转至树根，则将其转黑，整树黑高度也随之递增
         {  x->color = RB_BLACK; x->height++; return;  } //否则，x的父亲p必存在
      BinNodePosi<T> p = x->parent; if ( IsBlack( p ) ) return; //若p为黑，则可终止调整
      BinNodePosi<T> g = p->parent; //否则x的祖父必存在且为黑
      BinNodePosi<T> u = uncle( x ); //以下，视x叔父的颜色分别处理
      if ( IsBlack( u ) ) { // u为黑色（含NULL）时 /*DSA*///printf("  case RR-1:\n");
      // 若x与p同侧，则p由红转黑（x保持红）；若x与p异侧，则x由红转黑（p保持红）
         ( IsLChild( x ) == IsLChild( p ) ? p : x )->color = RB_BLACK;
      // g由黑转红并绕x旋转后，即完成修复
         g->color = RB_RED; rotateAt( x ); return;
      } else { //若u为红色 /*DSA*///printf("  case RR-2:\n");
         p->color = RB_BLACK; p->height++; //p由红转黑
         u->color = RB_BLACK; u->height++; //u由红转黑
         g->color = RB_RED; //在B-树中g相当于上交给父节点的关键码，故暂标记为红
         x = g; //继续上溯
      }
   } //while
}
