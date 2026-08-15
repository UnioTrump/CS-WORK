/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#pragma once

template <typename T> BinNodePosi<T> AVL<T>::insert( const T& e ) { //将关键码e插入AVL树中
   BinNodePosi<T>& x = search( e ); if ( x ) return x; //插入失败
   BinNodePosi<T> xx = x = new BinNode<T>( e, _hot ); _size++; //创建新节点x
// 此时，x的父亲_hot若增高，则其祖父有可能失衡
   for ( BinNodePosi<T> g = _hot; g; g->updateHeight(), g = g->parent ) //逐层上溯
      if ( !AvlBalanced( g ) ) { //一旦发现失衡祖先g，则
         rotateAt( tallerChild( tallerChild( g ) ) ); //（采用“3+4”算法）使之复衡
         break; //并随即终止（局部子树复衡后，高度必然复原；所有祖先亦必复衡）
      }
   return xx; //插入成功
} //至多会做O(1)次调整
