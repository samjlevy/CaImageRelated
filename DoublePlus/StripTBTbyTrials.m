function tbtSmall = StripTBTbyTrials(trialbytrial,condWant,trialsWant)

keepInds = false(numel(trialbytrial(condWant).trialsX),1);
keepInds(trialsWant) = true;

tbtSmall.trialsX = trialbytrial(condWant).trialsX(keepInds);
tbtSmall.trialsY = trialbytrial(condWant).trialsY(keepInds);
tbtSmall.trialPSAbool = trialbytrial(condWant).trialPSAbool(keepInds);
tbtSmall.trialRawTrace = trialbytrial(condWant).trialRawTrace(keepInds);
tbtSmall.sessID = trialbytrial(condWant).sessID(keepInds);
try
    tbtSmall.name = trialbytrial(condWant).name;
end
tbtSmall.lapNumber = trialbytrial(condWant).lapNumber(keepInds);
try
    tbtSmall.isCorrect = trialbytrial(condWant).isCorrect(keepInds);
end

try
    tbtSmall.lapSequence = trialbytrial(condWant).lapSequence(keepInds);
end

end