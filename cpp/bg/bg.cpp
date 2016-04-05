#include <iostream>
#include <string>
#include <stdio.h>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace cv;

int main(int argc, char** argv) {
    VideoCapture cap(0);
    namedWindow("Display Image", WINDOW_AUTOSIZE );
    Mat image;

    if(!cap.isOpened()) {
        std::cerr<<"Video Capture cannot be opened!"<<std::endl;
        return -1;
    }

    for(int i=0;;i++) {
        cap >> image;

        std::ostringstream frameNum;
        frameNum << i;
        // std::string fileName = "~/Desktop/bg/frame_" + frameNum.str() + ".jpg";
        std::string fileName = "data/" +frameNum.str() + ".jpg";

        std::cout<<fileName<<std::endl;
        if (!image.data) {
            std::cerr<<"No image data \n"<<std::endl;
            return -1;
        }

        imshow("Display Image", image);
        imwrite(fileName, image);
        if (waitKey(20)>0)
            break;
    }


    return 0;
}
