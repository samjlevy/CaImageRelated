function tbtSmall = StripTBT(trialbytrial,condWant,dayWant)

keepInds = trialbytrial(condWant).sessID==dayWant;

tbtSmall.trialsX = trialbytrial(condWant).trialsX(keepInds);
tbtSmall.trialsY = trialbytrial(condWant).trialsY(keepInds);
tbtSmall.trialPSAbool = trialbytrial(condWant).trialPSAbool(keepInds);
tbtSmall.trialRawTrace = trialbytrial(condWant).trialRawTrace(keepInds);
tbtSmall.sessID = trialbytrial(condWant).sessID(keepInds);
tbtSmall.name = trialbytrial(condWant).name;
tbtSmall.lapNumber = trialbytrial(condWant).lapNumber(keepInds);

end