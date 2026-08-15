/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#pragma once

template <typename T> BinNodePosi<T> BinNode<T>::insertLc( T const& e )
   { return lc = new BinNode<T>( e, this ); } //将e作为当前节点的左孩子插入二叉树

template <typename T> BinNodePosi<T> BinNode<T>::insertRc( T const& e )
   { return rc = new BinNode<T>( e, this ); } //将e作为当前节点的右孩子插入二叉树
