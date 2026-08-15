/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#pragma once

template <typename T> //Splay树伸展算法
BinNodePosi<T> Splay<T>::splay( BinNodePosi<T> v ) { //v为因最新访问而需伸展的节点
   BinNodePosi<T> p, g; //v的父亲与祖父
   while ( ( p = v->parent ) && ( g = p->parent ) ) { //自下而上，反复对v做双层伸展
      BinNodePosi<T> gg = g->parent; //每轮之后v都以原曾祖父（great-grand parent）为父
      switch ( ((p == g->rc) << 1) | (v == p->rc) ) { //视p、v的拐向，分四种情况
         case 0b00 : //zig-zig
            g->attachLc( p->rc ); p->attachLc( v->rc );
            p->attachRc( g );     v->attachRc( p );     break;
         case 0b01 : //zig-zag
            p->attachRc( v->lc ); g->attachLc( v->rc );
            v->attachRc( g );     v->attachLc( p );     break;
         case 0b10 : //zag-zig
            p->attachLc( v->rc ); g->attachRc( v->lc );
            v->attachLc( g );     v->attachRc( p );     break;
         default : //0b11 ~ zag-zag
            g->attachRc( p->lc ); p->attachRc( v->lc );
            p->attachLc( g );     v->attachLc( p );     break;
      }
      if ( !gg ) v->parent = NULL; //若v原先的曾祖父gg不存在，则v现在应为树根
      else //否则，gg此后应该以v作为左或右孩子
         ( g == gg->lc ) ? gg->attachLc( v ) : gg->attachRc( v );
      g->updateHeight(); p->updateHeight(); v->updateHeight();
   } //双层伸展结束时，必有g == NULL，但p可能非空
   if ( p = v->parent ) { //若p果真是根，则额外再做一次单旋
      if ( v == p->lc ) { p->attachLc( v->rc ); v->attachRc( p ); }
      else              { p->attachRc( v->lc ); v->attachLc( p ); }
      p->updateHeight(); v->updateHeight();
   }
   v->parent = NULL; return v;
} //调整之后新树根应为被伸展的节点，故返回该节点的位置以便上层函数更新树根
