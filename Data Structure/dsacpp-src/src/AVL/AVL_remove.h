/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#pragma once

template <typename T> bool AVL<T>::remove( const T& e ) { //从AVL树中删除关键码e
   BinNodePosi<T>& x = search( e ); if ( !x ) return false; //删除失败
   removeAt( x, _hot ); _size--; //先按BST规则删除之（此后，原节点之父_hot及其祖先均可能失衡）
   for ( BinNodePosi<T> g = _hot; g; g->updateHeight(), g = g->parent ) //逐层上溯
      if ( !AvlBalanced( g ) ) //每当发现失衡祖先g，都
         rotateAt( tallerChild( tallerChild( g ) ) ); //（采用“3+4”算法）使之复衡
   return true; //删除成功
} //可能需做Omega(logn)次调整
