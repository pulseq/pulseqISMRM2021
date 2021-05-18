system = mr.opts('rfRingdownTime', 20e-6, 'rfDeadTime', 100e-6, ...
                 'adcDeadTime', 20e-6);

seq=mr.Sequence(system);              % Create a new sequence object
Nx=4096;
Nrep=1;
adcDur=51.2e-3; 
rfDur=1000e-6; % increased to 1ms
TR=2000e-3;    % may increase to ~5s avoid T1 saturation
TE=10e-3; 
flip_angles=18;
    
% Define delays and ADC events
adc = mr.makeAdc(Nx,'Duration',adcDur, 'system', system, 'delay', TE-rfDur/2-system.rfRingdownTime);

delayTR=TR-mr.calcDuration(rf);
assert(delayTR>=0);

% Loop over repetitions and define sequence blocks
for f=1:flip_angles
    % Create non-selective pulse 
    rf = mr.makeBlockPulse(pi/flip_angles*f,'Duration',rfDur, 'system', system);
    % Loop over repetitions and define sequence blocks
    for i=1:Nrep
        seq.addBlock(rf);
        seq.addBlock(adc,mr.makeDelay(delayTR));
    end
end

% show the entire sequence
seq.plot();

% check whether the timing of the sequence is compatible with the scanner
[ok, error_report]=seq.checkTiming;

if (ok)
    fprintf('Timing check passed successfully\n');
else
    fprintf('Timing check failed! Error listing follows:\n');
    fprintf([error_report{:}]);
    fprintf('\n');
end

seq.setDefinition('Name', 'fid-mrf');

seq.write('fid.seq')       % Write to pulseq file
%seq.install('siemens');    % copy to scanner
