/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#pragma once

template <typename T> bool BST<T>::remove( const T& e ) { //从BST树中删除关键码e
   BinNodePosi<T>& x = search( e ); if ( !x ) return false; //确认目标存在（留意_hot的设置）
   removeAt( x, _hot ); //实施删除
   _size--; _hot->updateHeightAbove(); //更新全树高度，以及历代祖先的高度
   return true;
} //删除成功与否，由返回值指示
