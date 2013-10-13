function runAnalyzeFirst8Deep(model, analysisOnly, allCL)
% A simple script to run 8 of 9 (since 8 is easy to do in parallel)
% of the cell lines for which we have "deep protoeomic data". Can
% optionally run and analyze all cell lines.
%
%INPUT
% model   (reversible form; the following fields are required)
%   S            Stoichiometric matrix
%   lb           Lower bounds
%   ub           Upper bounds
%   rxns         reaction ids
%   
%   The following fields for model may be required depending
%   on the method:
%   b            Right hand side = dx/dt
%   c            Objective coefficients
%OPTIONAL INPUTS
%
% analysisOnly     Assumes simulations of interest are finished.
%                  and will redo analysis (useful if analysis 
%                  pipeline changes at all).
%
% allCL            If true, will run all available cell lines.

%
envConstrain = 'Medium_MaxMinSign';
%

protThreshDir = 'nci60prot_thresh';
micrThreshDir = 'nci60mRNA_thresh';

analysisLabel = '8DCLs';
CLs = {'MCF7', 'U251', 'COLO 205', 'CCRF-CEM', 'M14', 'NCI-H460', ...
       'OVAR_SKOV3', 'PROSTATE_PC3'};

if ~exist('allCL', 'var')
    allCL = false;
else
    analysisLabel = 'AllCLs';
    % !!! need to load CLs from NCI60_labels.csv
end

if ~exist('analysisOnly', 'var')
    analysisOnly = false;
end

% In case other constraints are added later
consString = '';
if exist('envConstrain', 'var')
    if length(envConstrain) > 0
        consString = [envConstrain '_'];
    end
end

% Run Simulations
if ~analysisOnly
    runMultiPerturbtion(model, protThreshDir, CLs, envConstrain, analysisLabel);
    runMultiPerturbtion(model, micrThreshDir, CLs, envConstrain, analysisLabel);
end
falconProtOutDir = ['FALCON_' analysisLabel '_simresults_' consString protThreshDir '/'];
falconMicrOutDir = ['FALCON_' analysisLabel '_simresults_' consString micrThreshDir '/'];


% Do Analysis. colOrder = [3 1 2] (last column (3) specifies nan or 0).
analyzeMultiPerturbation(model, falconProtOutDir, [3 1 2]);
analyzeMultiPerturbation(model, falconMicrOutDir, [3 1 2]);


%[meanVals, stdVals] = analyzeMultiPerturbation_ErrorBars(...
%    analysisDir, suffix, splitLabels)