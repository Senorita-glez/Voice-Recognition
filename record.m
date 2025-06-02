% Parámetros de grabación
fs = 16000;           % Frecuencia de muestreo (Hz)
n_bits = 16;          % Bits por muestra
n_channels = 1;       % Mono
duration = 2;         % Duración en segundos
num_recordings = 7;   % Número de grabaciones

recorder = audiorecorder(fs, n_bits, n_channels);

for i = 1:num_recordings
    fprintf('Grabando audio %d de %d... (Habla ahora)\n', i, num_recordings);
    recordblocking(recorder, duration);  % Graba durante 'duration' segundos
    fprintf('Grabación %d finalizada.\n', i);

    audio_data = getaudiodata(recorder);
    
    % Guarda el audio como archivo WAV
    filename = sprintf('audio%d.wav', i);
    audiowrite(filename, audio_data, fs);

    % Pausa de 1 segundo antes de la siguiente grabación
    pause(1);
end

disp('Todas las grabaciones se completaron.');
