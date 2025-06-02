function c = mfcc(s, fs)
% MFCC Compute Mel-frequency cepstral coefficients
% Inputs:
%   s  - señal de audio (vector)
%   fs - frecuencia de muestreo
% Output:
%   c  - matriz [num_coeffs × num_frames]

N = 256;                      % Tamaño de ventana (frame size)
M = 100;                      % Salto entre ventanas (hop size)
len = length(s);

% ⚠️ Verificación mínima
if len < N
    c = [];
    return;
end

numberOfFrames = 1 + floor((len - N) / M);
mat = zeros(N, numberOfFrames);

for i = 1:numberOfFrames
    index = (i-1)*M + 1;
    mat(:, i) = s(index:index+N-1);
end

hamW = hamming(N);
afterWinMat = diag(hamW) * mat;

% FFT
freqDomMat = fft(afterWinMat);
nby2 = 1 + floor(N/2);

% Banco de filtros Mel
filterBankMat = melFilterBank(20, N, fs);

% Espectro en escala Mel
ms = filterBankMat * abs(freqDomMat(1:nby2, :)).^2;

% 🛡️ Prevenir log(0)
ms(ms == 0) = 1e-10;

% Cepstrum
c = dct(log(ms));

% Eliminar coeficiente 0
c(1,:) = [];

% 🧼 Eliminar columnas que contienen NaN (por seguridad)
c(:, any(isnan(c), 1)) = [];
end
