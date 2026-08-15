/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#pragma once

/******************************************************************************************
 * RedBlack双黑调整算法：解决节点x与被其替代的节点均为黑色的问题
 * 分为三大类共四种情况：
 *    BB-1 ：2次颜色翻转，2次黑高度更新，1~2次旋转，不再递归
 *    BB-2R：2次颜色翻转，2次黑高度更新，0次旋转，不再递归
 *    BB-2B：1次颜色翻转，1次黑高度更新，0次旋转，需要递归
 *    BB-3 ：2次颜色翻转，2次黑高度更新，1次旋转，转为BB-1或BB2R
 ******************************************************************************************/
template <typename T> void RedBlack<T>::solveDoubleBlack( BinNodePosi<T> r ) {
   while ( 1 ) {
      BinNodePosi<T> p = r ? r->parent : _hot; if ( !p ) return; //r的父亲
      BinNodePosi<T> s = ( r == p->lc ) ? p->rc : p->lc; //r的兄弟
      if ( IsBlack( s ) ) { //兄弟s为黑
         // s的红孩子t：若左、右孩子皆红，左者优先；皆黑时为NULL
         BinNodePosi<T> t = IsRed( s->lc ) ? s->lc : IsRed( s->rc ) ? s->rc : NULL;
         if ( t ) { //黑s有红孩子：BB-1
            RBColor oldColor = p->color; //备份原子树根节点p颜色
         // 以下，通过旋转重平衡，并将新子树的左、右孩子染黑
            BinNodePosi<T> b = rotateAt( t ); //旋转
            if ( b->lc ) { b->lc->color = RB_BLACK; b->lc->updateHeight(); } //左子
            if ( b->rc ) { b->rc->color = RB_BLACK; b->rc->updateHeight(); } //右子
            b->color = oldColor; b->updateHeight(); return; //子树新根继承原根的颜色
         } else { //黑s无红孩子
            s->color = RB_RED; s->height--; //s转红
            if ( IsRed( p ) ) { p->color = RB_BLACK; return; } //BB-2R：p转黑，但黑高度不变
            else { p->height--; r = p; } //BB-2B：p保持黑，但黑高度下降；继续上溯
         }
      } else { //兄弟s为红：BB-3
         s->color = RB_BLACK; p->color = RB_RED; //s转黑，p转红
         BinNodePosi<T> t = ( s == p->lc ) ? s->lc : s->rc; //取t与其父s同侧
         _hot = p; rotateAt( t ); //对t及其父亲、祖父做平衡调整
         //继续迭代，修正r处的双黑——此时的p已转红，故接下来只能是BB-1或BB-2R
      }
   } //while
}
