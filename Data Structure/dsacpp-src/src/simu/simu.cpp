/******************************************************************************************
 * Data Structures in C++
 * ISBN: 7-302-33064-6 & 7-302-33065-3 & 7-302-29652-2 & 7-302-26883-3
 * Junhui DENG, deng@tsinghua.edu.cn
 * Computer Science & Technology, Tsinghua University
 * Copyright (c) 2003-2024.
 ******************************************************************************************/

/*DSA*/#include "simu.h"

void simulate( Rank wins, Rank servTime ) { //按指定窗口数、服务总时间模拟银行业务
   Queue<Customer>* window = new Queue<Customer>[wins]; //为每一窗口创建一个队列
   for ( Rank now = 0; now < servTime; now++ ) { //在下班之前，每隔一个单位时间
      if ( rand() % ( 1 + wins ) ) { //新顾客以wins/(wins + 1)的概率到达
         Customer c ; c.time = 1 + rand() % 98; //新顾客到达，服务时长随机确定
         c.winId = bestWindow( window, wins ); //找出最佳（最短）的服务窗口/*DSA*/ToDo: 更精细的策略
         window[c.winId].enqueue( c ); //新顾客加入对应的队列
      }
      for ( Rank i = 0; i < wins; i++ ) //分别检查
         if ( !window[i].empty() ) //各非空队列
            if ( -- window[i].front().time <= 0 ) //队首顾客的服务时长减少一个单位
               window[i].dequeue(); //服务完毕的顾客出列，由后继顾客接替
      /*DSA*/displayProgress( window, wins, now ); //显示当前各（窗口）队列情况
      /*DSA*/delay > 0 ? //若命令行指定的时间间隔为正数
      /*DSA*/  _sleep( delay ) : //则做相应的延迟
      /*DSA*/  getchar(); //否则，以手动方式单步演示
   } //for
   delete [] window; //释放所有队列（此前，~List()会自动清空队列）
}