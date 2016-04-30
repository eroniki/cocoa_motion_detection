%folder containing data (a sequence of jpg images)
%dirname = '../image';
dirname = '../data/image';
%find the images, initialize some variables
dirlist = dir(sprintf('%s/*.pgm', dirname));
%nframes = numel(dirlist);
startFrame=1;
nframes = numel(dirlist);
fft_tag=1;

for i=startFrame:nframes
    %read a new image, convert to double, convert to greyscale
    img = imread(sprintf('%s/%s', dirname, dirlist(i).name));
    figure(2);
    imagesc(img);
    figure(1);
    k = waitforbuttonpress; 
    J = histeq(img);
    imagesc(J);
    
    if fft_tag==1
     Y = fft2(double(img));
     figure(3);
     imshow(abs(fftshift(Y))), colormap gray
     title('Image A FFT2 Magnitude')   
    end
    fprintf('fuck_you\n');
end