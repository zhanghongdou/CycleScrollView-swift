# CycleScrollView-Swift

<html>
<body>
<h2>什么是 CycleScrollView-Swift</h2>
<p>这是一个基于swift语言实现图片轮播的封装</p>

<h2>效果图展示</h2>

<h3>效果图1</h3>
<p><img src="picture/0B93969F-F292-4924-98CC-678F136FA543.png"/></p>

<h3>效果图2</h3>
<p><img src="picture/558AD908-C480-42B7-B1A8-74F1CC62597E.png"/></p>


<h2>使用方法</h2>
<p>//实例化进行添加在指定的View上面</br>
let cycleView = CycleScrollView.init(frame: CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 200), animationDuration: 3.0)</br>
        cycleView.backgroundColor = UIColor.orangeColor()</br>
        self.view.addSubview(cycleView)</br>
        
//设置轮播图的数组URL</br>
        let dataArray = ["http://img04.sogoucdn.com/app/a/100520020/50c11a6a4b7a4da664e93a9cf4c061ce",</br>
                         "http://img04.sogoucdn.com/app/a/100520024/1f9163519dac6b2138c7d96b5598467e",</br>
                         "http://img01.sogoucdn.com/app/a/100520024/e2f057ede9d3cafabed15418bad2ee17",</br>
                         "http://img01.sogoucdn.com/app/a/100520020/2001859ba6fca0a525728c7568782d89",</br>
                         "http://img04.sogoucdn.com/app/a/100520024/f4d580ab0d9f5d514c9471b23bba0561",</br>
                         "http://img03.sogoucdn.com/app/a/100520024/30e8009fb8710f519b565b1cd17df7ec",</br>
                         "http://img02.sogoucdn.com/app/a/100520020/992e6ea334d3d1c34abfa5ea1ec0978a"]</br>
  //创建加载图片的ImageView</br>
        for index in 0..<dataArray.count {</br>
            let imageView = UIImageView.init(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200))</br>
            imageView.sd_setImageWithURL(NSURL(string: dataArray[index]))</br>
            self.imageViewArray.addObject(imageView)</br>
        }      </br> 
        
        
        //闭包返回相应的View</br> 
        cycleView.fetchContentViewAtIndex = {(pageIndex: NSInteger) in</br> 
            return (self.imageViewArray[pageIndex] as! UIView)</br> 
        }</br> 
          
        
        //这个是吧所有的URL传过去，这一步必须做</br> 
        cycleView.imageURLArray = dataArray</br> 
        //传入相应的count</br> 
        cycleView.totalPageCount = self.imageViewArray.count</br> 
        //设置pageContol的count</br> 
        cycleView.pageControl?.numberOfPages = self.imageViewArray.count</br> 
        //点击的闭包</br> 
        cycleView.tapActionBlock = { (pageIndex: NSInteger) in</br> 
            print(pageIndex)</br> 
        }</br> 
       </p>
</body>

</html>