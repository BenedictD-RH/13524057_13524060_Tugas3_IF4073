# 13524057_13524060_Tugas3_IF4073
## Deskripsi Program

Program ini merupakan sebuah aplikasi MATLAB berbasis GUI untuk melakukan segmentasi citra. Metode segmentasi yang dapat dilakukan program ini mencakup tiga kelompok teknik, yaitu segmentasi berdasarkan deteksi tepi, segmentasi dengan metode _split and merge_, dan segmentasi semantik menggunakan _Convolutional Neural Network_ (CNN).



## Requirements

### MATLAB
- **Version:** R2026a or higher
- **Toolbox:** 
    - Image Processing Toolbox
    - Parallel Computing Toolbox
    - Deep Learning Toolbox
    - Computer Vision Toolbox 
    - Deep Learning Toolbox Model for ResNet-18 Network

## How to run

### Run CNN model training
```bash
cd src
matlab -batch "run_cnn_training('training_data', 'camvidNet.mat')"
```

### Running GUI app
```bash
cd src
matlab -r "run('app1.mlapp')"
```

## Anggota Kelompok

| Nama Anggota | NIM |
| --- | --- |
| **Benedict Darrel Setiawan** | 13524057 |
| **Steven Tan** | 13524060 |