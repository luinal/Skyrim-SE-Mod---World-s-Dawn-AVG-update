Scriptname XTDUtil  Hidden 

string Function ConvertFloatToText(float ValueToConvert, string divider=".", int offset=2) global
	int i = StringUtil.Find((ValueToConvert as string), divider, 0) + offset
	Return (StringUtil.Substring((ValueToConvert as string), 0, i))
Endfunction

string Function F2S(float ValueToConvert, string divider=".", int offset=2) global
	int i = StringUtil.Find((ValueToConvert as string), divider, 0) + offset
	Return (StringUtil.Substring((ValueToConvert as string), 0, i))
Endfunction

String Function ConvertAVToText(Actor akActor, string nativeAV, string prefix="+", string suffix="%", float AVMult=1.0, float nativeOffset=0.0, bool bDecimal=FALSE) global
	float f
	int offset = 2
	if (bDecimal)
		f = ((1.0 - akActor.GetActorValue(nativeAV) + nativeOffset) * AVMult)
	else
		f = ((akActor.GetActorValue(nativeAV) + nativeOffset) * AVMult)
	endif
	string s = (f as string)
	int i = StringUtil.Find(s, ".", 0) + offset
	if (f <= 0.0)
		prefix = ""
	endif
	Return (prefix + StringUtil.Substring(s, 0, i) + suffix)
Endfunction

String Function ChanceToString(Actor akActor, string nativeAV, float ValueToConvert, string prefix="+", string suffix="%", int offset=2) global
    float f = (ValueToConvert + ((akActor.GetActorValue(nativeAV) * 0.01) * ValueToConvert))
    string s = (f as string)
    int i = StringUtil.Find(s, ".", 0) + offset
    if (f <= 0.0)
        prefix = ""
    endif
    return (prefix + StringUtil.Substring(s, 0, i) + suffix)
Endfunction

Float Function CalculateMyOdds(Actor akActor, string nativeAV, float gvValue) global
    return (gvValue + ((akActor.GetActorValue(nativeAV) * 0.01) * gvValue))
Endfunction

Float Function RNDF(Float fMin = 0.0, Float fMax = 100.0) global
	Return Utility.RandomFloat(fMin, fMax)
Endfunction

int Function RoundFloat(Float f) global
;	Return (f as Int) ; better?
	Return (Math.Floor(f))
EndFunction