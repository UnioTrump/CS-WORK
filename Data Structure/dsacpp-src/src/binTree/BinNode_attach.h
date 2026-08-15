/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#pragma once

template <typename T> void BinNode<T>::attachLc( BinNodePosi<T> x )
   { lc = x; if ( x ) x->parent = this; } //接入左子树

template <typename T> void BinNode<T>::attachRc( BinNodePosi<T> x )
   { rc = x; if ( x ) x->parent = this ; } //接入右子树
