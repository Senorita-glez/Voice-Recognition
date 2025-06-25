%% Grabar y clasificar un audio con modelo entrenado
clear; clc;

% Parámetros de grabación
fs = 16000;      % Frecuencia de muestreo
duracion = 2.0;  % Duración en segundos
disp('Grabando audio...');
recObj = audiorecorder(fs, 16, 1);  % mono, 16 bits
recordblocking(recObj, duracion);
audio = getaudiodata(recObj);

% Guardar audio grabado
audiowrite('prueba.wav', audio, fs);
fprintf('Audio grabado y guardado como grabacion.wav\n');

% Cargar modelo (elige uno)
load modeloRF_BandaNorm.mat  % Random Forest
% load modeloSVM_BandaNorm.mat  % SVM si usas ese

% Preprocesamiento
audio = bandpass(audio, [300 3400], fs);
audio = audio / max(abs(audio));

% MFCC
mfccs = mfcc(audio, fs);
mfccs = mfccs(:, 1:min(13, size(mfccs,2)));

if size(mfccs,1) < 2
    error('Audio muy corto o inválido.');
end

% Características
mfcc_mean = mean(mfccs, 1);
mfcc_std  = std(mfccs, 0, 1);
features = [mfcc_mean mfcc_std];
features(isnan(features)) = 0;

% Clasificación
if exist('modeloRF', 'var')
    features_norm = normalize(features);
    resultado = predict(modeloRF, features_norm);
    palabra = resultado{1};
    fprintf('🔊 Palabra predicha (Random Forest): %s\n', palabra);
elseif exist('modeloSVM', 'var')
    palabra = string(predict(modeloSVM, features));
    fprintf('🔊 Palabra predicha (SVM): %s\n', palabra);
else
    error('No se ha cargado un modelo válido.');
end
