/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

/*DSA*/#include "huffman_PQ.h"

HuffTree delMax( HuffForest* forest ) { //从Huffman森林中，找出优先级最高（权重最小）的树
   ListNodePosi<HuffTree> m = forest->first(); //从首节点出发
   for ( ListNodePosi<HuffTree> p = m->succ; forest->valid( p ); p = p->succ ) //遍历所有节点
      if ( m->data < p->data ) //不断更新（因已定义比较器，故能简捷）
         m = p; //优先级更高（权重更小）者
   return forest->remove( m ); //取出最高者并返回
} //O(n)，改用优先级队列后可做到O(logn)

HuffTree generateTree( HuffForest* forest ) { //由Huffman森林，构造出Huffman编码树
   while ( 1 < forest->size() ) { //每迭代一步，森林中都会减少一棵树
      HuffTree T1 = delMax( forest ), T2 = delMax( forest ); //取出权重最小的两棵树
      /*DSA*/printf( "Merging " ); print( T1.root()->data ); printf( " with " ); print( T2.root()->data ); printf( " ...\n" );
      HuffTree S; //将其合并成一棵新树
      S.insert( HuffChar ( '^', T1.root()->data.weight + T2.root()->data.weight ) );
      S.attach( T2, S.root() ); S.attach( S.root(), T1 ); //T2权重不小于T1
      forest->insertLast( S ); //再插回至森林
   } //森林中最终唯一所剩的那棵树，即Huffman编码树（且其层次遍历序列必然单调非增）
   return forest->first()->data; //故返回之
}