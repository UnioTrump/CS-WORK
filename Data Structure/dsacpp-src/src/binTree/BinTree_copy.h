/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#pragma once

template <typename T>
BinNodePosi<T> NodeCopy( BinNodePosi<T> p, BinNodePosi<T> s ) {
   if ( !s ) return NULL;
   BinNodePosi<T> t = new BinNode<T>( s->data, p, NULL, NULL, s->height, s->npl, s->color );
   t->lc = NodeCopy( t, s->lc );
   t->rc = NodeCopy( t, s->rc );
   return t;
}

template <typename T> //通过复制来构造二叉树
BinTree<T>::BinTree( BinTree<T> const & s ) {
   _size = s.size();
   _root = NodeCopy<T>( NULL, s._root );
}
