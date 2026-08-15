/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

#pragma once

template <typename K, typename V> Hashtable<K, V>::~Hashtable() { //析构前释放桶数组及非空词条
   for ( Rank i = 0; i < M; i++ ) //逐一检查各桶
      if ( ht[i] ) delete ht[i]; //释放非空的桶
   delete ht; //释放桶数组
   delete removed; //释放懒惰删除标记
}
