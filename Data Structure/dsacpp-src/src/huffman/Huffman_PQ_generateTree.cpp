/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

/*DSA*/#include "Huffman_PQ.h"

// forest基于优先级队列实现，此算法适用于符合PQ接口的任何实现方式
// 为Huffman_PQ_List、Huffman_PQ_ComplHeap和Huffman_PQ_LeftHeap共用
// 编译前对应工程只需设置相应的标志：DSA_PQ_List、DSA_PQ_ComplHeap或DSA_PQ_LeftHeap
HuffTree generateTree( HuffForest* forest ) { //由Huffman森林，构造出Huffman编码树
   while ( 1 < forest->size() ) { //每迭代一步，森林中都会减少一棵树
      HuffTree T1 = forest->delMax(), T2 = forest->delMax(); //取出权重最小的两棵树
      /*DSA*/printf( "Merging " ); print( T1.root()->data ); printf( " with " ); print( T2.root()->data ); printf( " ...\n" );
      HuffTree S; //将其合并成一棵新树
      S.insert( HuffChar ( '^', T1.root()->data.weight + T2.root()->data.weight ) );
      S.attach( T2, S.root() ); S.attach( S.root(), T1 ); //T2权重不小于T1
      forest->insert( S ); //再插回至森林
   } //森林中最终唯一所剩的那棵树，即Huffman编码树（且其层次遍历序列必然单调非增）
   return forest->delMax(); //故返回之
}