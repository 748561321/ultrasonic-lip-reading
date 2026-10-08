import wave
import numpy as np
import struct
import scipy.signal as signal
import matplotlib.pyplot as plt
import scipy.io.wavfile as wav
import matplotlib
import wave
from scipy import *
from pylab import *
from scipy.fft import fft

import os
import win32api,win32con   
def get_desktop():
        key = win32api.RegOpenKey(win32con.HKEY_CURRENT_USER,\
                              r'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',\
                              0,win32con.KEY_READ)
        return win32api.RegQueryValueEx(key,'Desktop')[0]

# 画时间-频率图
def pic(filename=get_desktop()+'\\Zii.wav'):
    matplotlib.rc("font", family='SimHei')  # 显示中文
    matplotlib.rcParams['axes.unicode_minus'] = False  # 显示符号
    fs, Sig = wav.read(filename)
    plt.figure()
    plt.subplot(2, 1, 1)  # 第一个子图
    cnt = 0
    for i in Sig[:]:
        cnt = cnt + 1
    middle = cnt // 2
    SIZE = 6250
    bound = min(cnt, middle + SIZE)
    print(middle)
    print(bound)
    # 631680
    plt.specgram(Sig[middle:bound, 0], Fs=fs, scale_by_freq=True, sides='default')
    plt.colorbar()  # format='%+2.0f dB'
    plt.subplot(2, 1, 2)  # 第二个子图
    plt.specgram(Sig[middle:bound, 1], Fs=fs, scale_by_freq=True, sides='default')  # 绘制语谱图
    plt.colorbar(format='%+2.0f dB')
    plt.savefig(get_desktop() + '\\picture\\' + filename.split('\\')[-1][:-4] + '.jpg')


# 画时间-频率图
def Plot_fft_freq_chart(filename, PLOT=False):
    wavefile = wave.open(filename, 'r')  # open for writing
    nchannels = wavefile.getnchannels()
    sample_width = wavefile.getsampwidth()
    framerate = wavefile.getframerate()
    numframes = wavefile.getnframes()
    print("channel", nchannels)
    print("sample_width", sample_width)
    print("framerate", framerate)
    print("numframes", numframes)
    y = np.zeros(numframes)
    for i in range(numframes):
        val = wavefile.readframes(1)
        left = val[0:2]
        # right = val[2:4]
        v = struct.unpack('h', left)[0]
        y[i] = v

    Fs = framerate
    try:
        data, freqs, bins, im = specgram(y, NFFT=1024, Fs=Fs, noverlap=900)
        mm = data[127]
        mm = 10. * np.log10(mm + 1e-4)

    except Exception as e:
        print("error is: ", e)
        return -50
    freq1khz_value = mean(mm)
    print(freq1khz_value)
    if PLOT:
        show()
    return freq1khz_value


# 可以用来生成特定频率范围的wav文件,默认为4s
def Generate_Wav(file_name=get_desktop() + '\\audio\\sweep.wav'):
    # define the params of wave
    channels = 1
    sampwidth = 2
    framerate = 96000
    frequency_begin = 24000
    frequency_end = 44000
    # define the time of wave
    TIME = 0.005
    # generate the time bar
    t = np.arange(0, TIME, 1.0 / framerate)
    # generate the chirp signal from 300 to 3300Hz
    wave_data = signal.chirp(t, frequency_begin, TIME, frequency_end, method='linear') * 1000

    periodSize = size(wave_data, 0)
    new_wave = []
    for i in range(0, 200 * 4):
        startIdx = i * 480
        endIdx = (i + 1) * 480
        new_wave[startIdx:endIdx] = wave_data
    new_wave = np.array(new_wave)
    # cast to the type of short
    new_wave = new_wave.astype(np.short)
    # open a wav document
    F = wave.open(file_name, "wb")
    # set wav params
    F.setnchannels(channels)
    F.setsampwidth(sampwidth)
    F.setframerate(framerate)
    # turn the data to string
    F.writeframes(new_wave.tobytes())
    F.close()


if __name__ == '__main__':

    for root,dirs,files in os.walk(get_desktop() +"\\audio\\"):
        for name in files:
                if name[-4:] == '.wav':
                     # Generate_Wav(path)
                     path = get_desktop() + "\\audio\\" + name
                     print(path)
                     pic(path)
    
    
    # Plot_fft_freq_chart(path, True)

