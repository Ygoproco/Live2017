Auxiliary={}
aux=Auxiliary

--To be removed after next core update
if not Duel.GetLocationCountFromEx then
	function Duel.GetLocationCountFromEx(tp)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)
	end
end
local rmf=Card.IsAbleToRemove
Card.IsAbleToRemove=function(c,player,pos)
	if not rmf(c,player) then return false end
	return not pos or not c:IsType(TYPE_TOKEN) or bit.band(pos,POS_FACEDOWN)<=0
end
local rmfc=Card.IsAbleToRemoveAsCost
Card.IsAbleToRemoveAsCost=function(c,pos)
	if not rmfc(c) then return false end
	return not pos or not c:IsType(TYPE_TOKEN) or bit.band(pos,POS_FACEDOWN)<=0
end
--to be updated in the next update/updted core-wise
Card.EnableCounterPermit=function(c,countertype,location)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_COUNTER_PERMIT+countertype)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	e1:SetCondition(function(e)
		local self=e:GetHandler()
		if self:IsOnField() then
			if not location or tempchk then return true end
			local fz=bit.band(location,LOCATION_FZONE)
			local pz=bit.band(location,LOCATION_PZONE)
			local loc=bit.band(location,LOCATION_ONFIELD)
			return self:IsLocation(loc) or (fz>0 and self:IsLocation(LOCATION_SZONE) and self:GetSequence()==5) 
				or (pz>0 and self:IsLocation(LOCATION_SZONE) and (self:GetSequence()==6 or self:GetSequence()==7))
		end
		return true
	end)
	c:RegisterEffect(e1)
end


function Auxiliary.Stringid(code,id)
	return code*16+id
end
function Auxiliary.Next(g)
	local first=true
	return	function()
				if first then first=false return g:GetFirst()
				else return g:GetNext() end
			end
end
function Auxiliary.NULL()
end
function Auxiliary.TRUE()
	return true
end
function Auxiliary.FALSE()
	return false
end
function Auxiliary.AND(f1,f2)
	return	function(a,b,c)
				return f1(a,b,c) and f2(a,b,c)
			end
end
function Auxiliary.OR(f1,f2)
	return	function(a,b,c)
				return f1(a,b,c) or f2(a,b,c)
			end
end
function Auxiliary.NOT(f)
	return	function(a,b,c)
				return not f(a,b,c)
			end
end
function Auxiliary.BeginPuzzle(effect)
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TURN_END)
	e1:SetCountLimit(1)
	e1:SetOperation(Auxiliary.PuzzleOp)
	Duel.RegisterEffect(e1,0)
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_SKIP_DP)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,0)
	local e3=Effect.GlobalEffect()
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_SKIP_SP)
	e3:SetTargetRange(1,0)
	Duel.RegisterEffect(e3,0)
end
function Auxiliary.PuzzleOp(e,tp)
	Duel.SetLP(0,0)
end
function Auxiliary.IsDualState(effect)
	local c=effect:GetHandler()
	return not c:IsDisabled() and c:IsDualState()
end
function Auxiliary.IsNotDualState(effect)
	local c=effect:GetHandle()
	return c:IsDisabled() or not c:IsDualState()
end
function Auxiliary.DualNormalCondition(effect)
	local c=effect:GetHandler()
	return c:IsFaceup() and not c:IsDualState()
end
function Auxiliary.EnableDualAttribute(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DUAL_SUMMONABLE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCondition(aux.DualNormalCondition)
	e2:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REMOVE_TYPE)
	e3:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e3)
end
--register effect of return to hand for Spirit monsters
function Auxiliary.EnableSpiritReturn(c,event1,...)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(event1)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(Auxiliary.SpiritReturnReg)
	c:RegisterEffect(e1)
	for i,event in ipairs{...} do
		local e2=e1:Clone()
		e2:SetCode(event)
		c:RegisterEffect(e2)
	end
end
function Auxiliary.SpiritReturnReg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0x1ee0000+RESET_PHASE+PHASE_END)
	e1:SetCondition(Auxiliary.SpiritReturnCondition)
	e1:SetTarget(Auxiliary.SpiritReturnTarget)
	e1:SetOperation(Auxiliary.SpiritReturnOperation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	c:RegisterEffect(e2)
end
function Auxiliary.SpiritReturnCondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsHasEffect(EFFECT_SPIRIT_DONOT_RETURN) then return false end
	if e:IsHasType(EFFECT_TYPE_TRIGGER_F) then
		return not c:IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN)
	else return c:IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN) end
end
function Auxiliary.SpiritReturnTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function Auxiliary.SpiritReturnOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
function Auxiliary.IsUnionState(effect)
	local c=effect:GetHandler()
	return c:IsHasEffect(EFFECT_UNION_STATUS)
end
function Auxiliary.SetUnionState(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNION_STATUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e1)
	if c.old_union then
		local e2=e1:Clone()
		e2:SetCode(EFFECT_OLDUNION_STATUS)
		c:RegisterEffect(e2)
	end
end
function Auxiliary.CheckUnionEquip(uc,tc)
	ct1,ct2=tc:GetUnionCount()
	if uc.old_union then return ct1==0
	else return ct2==0 end
end
function Auxiliary.TargetEqualFunction(f,value,a,b,c)
	return	function(effect,target)
				return f(target,a,b,c)==value
			end
end
function Auxiliary.TargetBoolFunction(f,a,b,c)
	return	function(effect,target)
				return f(target,a,b,c)
			end
end
function Auxiliary.FilterEqualFunction(f,value,a,b,c)
	return	function(target)
				return f(target,a,b,c)==value
			end
end
function Auxiliary.FilterBoolFunction(f,a,b,c)
	return	function(target)
				return f(target,a,b,c)
			end
end
function Auxiliary.NonTuner(f,a,b,c)
	return	function(target)
				return target:IsNotTuner() and (not f or f(target,a,b,c))
			end
end
--Synchro monster, 1 tuner + n or more monsters
function Auxiliary.AddSynchroProcedure(c,f1,f2,ct)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Auxiliary.SynCondition(f1,f2,ct,99))
	e1:SetTarget(Auxiliary.SynTarget(f1,f2,ct,99))
	e1:SetOperation(Auxiliary.SynOperation(f1,f2,ct,99))
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
end
function Auxiliary.SynCondition(f1,f2,minct,maxc)
	return	function(e,c,smat,mg)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local ft=Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)
				local ct=-ft
				local minc=minct
				if minc<ct then minc=ct end
				if maxc<minc then return false end
				if smat and smat:IsType(TYPE_TUNER) and (not f1 or f1(smat)) then
					return Duel.CheckTunerMaterial(c,smat,f1,f2,minc,maxc,mg) end
				return Duel.CheckSynchroMaterial(c,f1,f2,minc,maxc,smat,mg)
			end
end
function Auxiliary.SynTarget(f1,f2,minct,maxc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg)
				local g=nil
				local ft=Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)
				local ct=-ft
				local minc=minct
				if minc<ct then minc=ct end
				if smat and smat:IsType(TYPE_TUNER) and (not f1 or f1(smat)) then
					g=Duel.SelectTunerMaterial(c:GetControler(),c,smat,f1,f2,minc,maxc,mg)
				else
					g=Duel.SelectSynchroMaterial(c:GetControler(),c,f1,f2,minc,maxc,smat,mg)
				end
				if g then
					g:KeepAlive()
					e:SetLabelObject(g)
					return true
				else return false end
			end
end
function Auxiliary.SynOperation(f1,f2,minct,maxc)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
				g:DeleteGroup()
			end
end
--Synchro monster, 1 tuner + 1 monster
function Auxiliary.AddSynchroProcedure2(c,f1,f2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Auxiliary.SynCondition(f1,f2,1,1))
	e1:SetTarget(Auxiliary.SynTarget(f1,f2,1,1))
	e1:SetOperation(Auxiliary.SynOperation(f1,f2,1,1))
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
end
function Auxiliary.TuneMagFilter2(c,f,tp)
	return not f(c,nil,tp)
end
function Auxiliary.XyzAlterFilter(c,alterf,xyzc,tp)
	return alterf(c) and c:IsCanBeXyzMaterial(xyzc) and (c:IsControler(tp) or c:IsHasEffect(EFFECT_XYZ_MATERIAL))
end
--Xyz monster, lv k*n
function Auxiliary.AddXyzProcedure(c,f,lv,ct,alterf,desc,maxct,op,mustbemat)
	--mustbemat for Startime Magician
	if not maxct then maxct=ct end	
	if c.xyz_filter==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.xyz_filter=function(mc,ignoretoken) return mc and (not f or f(mc)) and mc:IsXyzLevel(c,lv) and (not mc:IsType(TYPE_TOKEN) or ignoretoken) end
		mt.minxyzct=ct
		mt.maxxyzct=maxct
	end	
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1073)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Auxiliary.XyzCondition(f,lv,ct,maxct,mustbemat))
	e1:SetTarget(Auxiliary.XyzTarget(f,lv,ct,maxct,mustbemat))
	e1:SetOperation(Auxiliary.XyzOperation(f,lv,ct,maxct,mustbemat))
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	if alterf then
		local e2=e1:Clone()
		e2:SetDescription(desc)
		e2:SetCondition(Auxiliary.XyzCondition2(alterf,op))
		e2:SetTarget(Auxiliary.XyzTarget2(alterf,op))
		e2:SetOperation(Auxiliary.XyzOperation2(alterf,op))
		c:RegisterEffect(e2)
	end
	if not xyztemp then
		xyztemp=true
		xyztempg0=Group.CreateGroup()
		xyztempg0:KeepAlive()
		xyztempg1=Group.CreateGroup()
		xyztempg1:KeepAlive()
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		e3:SetCode(EVENT_ADJUST)
		e3:SetCountLimit(1)
		e3:SetOperation(Auxiliary.XyzMatGenerate)
		Duel.RegisterEffect(e3,0)
	end
end
function Auxiliary.XyzMatGenerate(e,tp,eg,ep,ev,re,r,rp)
	local tck0=Duel.CreateToken(0,946)
	xyztempg0:AddCard(tck0)
	local tck1=Duel.CreateToken(1,946)
	xyztempg1:AddCard(tck1)
end
--Xyz Summon(normal)
function Auxiliary.XyzM12(c,f,lv,xyz,xg,mustbemat,tp)
	return Auxiliary.XyzMatFilter(c,f,lv,xyz,tp) or Auxiliary.XyzSubMatFilter(c,rk,xyz,xg,mustbemat)
end
function Auxiliary.XyzMatFilter(c,f,lv,xyz,tp)
	return (c:IsFaceup() or not c:IsOnField()) and (not f or f(c)) and c:IsXyzLevel(xyz,lv) and c:IsCanBeXyzMaterial(xyz) 
		and (c:IsControler(tp) or c:IsHasEffect(EFFECT_XYZ_MATERIAL))
end
function Auxiliary.XyzSubMatFilter(c,f,lv,xyz,xg,mustbemat)
	if c:IsLocation(LOCATION_GRAVE) then
		--Graveyard Material
		return c:IsHasEffect(511002793) and (not f or f(c)) and c:IsXyzLevel(xyz,lv) and c:IsCanBeXyzMaterial(xyz)
	else
		--Solid Overlay-type OR Orichalcum Chain (minus material)
		if mustbemat then return false end
		if c:IsHasEffect(511002116) then return true end
		return c:GetFlagEffect(511000189)==lv and xg:IsExists(Auxiliary.XyzSubFilterChk,1,nil,f)
	end
end
function Auxiliary.XyzSubFilterChk(c,f)
	return (not f or f(c))
end
function Auxiliary.XyzFilterChk(c,mg,xyz,tp,minc,maxc,matg,ct,nodoub,notrip,sg,min,matct,mustbemat)
	local tg
	local g=mg:Clone()
	if matg==nil or matg:GetCount()==0 then tg=Group.CreateGroup() else tg=matg:Clone() end
	g:RemoveCard(c)
	tg:AddCard(c)
	local tsg=false
	if sg then
		tsg=sg:Clone()
		tsg:RemoveCard(c)
	end
	local gg=tg:Filter(Auxiliary.ValidXyzMaterial,nil)
	if gg:IsExists(Auxiliary.TuneMagXyzFilter,1,nil,gg,tp) then return false end
	local ctc=ct+1
	local matct2=matct
	if not c:IsHasEffect(511002116) and min then
		matct2=matct+1
	end
	if min and matct2>min then return false end
	if (not min or matct2==min) and ctc>=minc and ctc<=maxc and tg:IsExists(Auxiliary.XyzFCheck,1,nil,tp) 
		and not tg:IsExists(Auxiliary.XyzMatNumCheck,1,nil,tg:GetCount()) then return true end
	if ctc>maxc then return false end
	local res2=false
	local res3=false
	--Extra Equip Material
	local eqg=c:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175)
	if not sg and not mustbemat then
		g:Merge(eqg)
	end
	local isDouble=false
	--Double Material
	if not mustbemat and not nodoub and c:IsHasEffect(511001225) and (not c.xyzlimit2 or c.xyzlimit2(xyz)) then
		if ctc+1<=maxc then
			isDouble=true
			res2=true
		end
		if (not min or matct2==min) and ctc+1>=minc and ctc+1<=maxc and tg:IsExists(Auxiliary.XyzFCheck,1,nil,tp) 
			and not tg:IsExists(Auxiliary.XyzMatNumCheck,1,nil,tg:GetCount()) then return true end
	end
	--Triple Material
	if not mustbemat and not notrip and c:IsHasEffect(511003001) and (not c.xyzlimit3 or c.xyzlimit3(xyz)) then
		if ctc+2<=maxc then
			res3=true
		end
		if (not min or matct2==min) and ctc+2>=minc and ctc+2<=maxc and tg:IsExists(Auxiliary.XyzFCheck,1,nil,tp) 
			and not tg:IsExists(Auxiliary.XyzMatNumCheck,1,nil,tg:GetCount()) then return true end
	end
	return g:IsExists(Auxiliary.XyzFilterChk,1,nil,g,xyz,tp,minc,maxc,tg,ctc,false,false,tsg,min,matct2,mustbemat) 
		or (res2 and g:IsExists(Auxiliary.XyzFilterChk,1,nil,g,xyz,tp,minc,maxc,tg,ctc+1,false,false,tsg,min,matct2,mustbemat))
		or (res3 and g:IsExists(Auxiliary.XyzFilterChk,1,nil,g,xyz,tp,minc,maxc,tg,ctc+2,false,false,tsg,min,matct2,mustbemat))
end
function Auxiliary.XyzMatNumCheck(c,ct)
	return c:GetFlagEffect(91110378)>0 and c:GetFlagEffectLabel(91110378)~=ct
end
function Auxiliary.XyzFCheck(c,tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or (c:IsLocation(LOCATION_MZONE) and c:IsControler(tp))
end
function Auxiliary.ValidXyzMaterial(c)
	return not c:IsHasEffect(511001175) and not c:IsHasEffect(511002116)
end
function Auxiliary.TuneMagXyzFilter(c,g,tp)
	return c:IsHasEffect(73941492) and c.xyzlimitfilter and g:IsExists(Auxiliary.TuneMagFilter2,1,c,c.xyzlimitfilter,tp)
end
function Auxiliary.ExtraXyzMaterial(c,g,tp,ct,max)
	local gg=g:Filter(Auxiliary.ValidXyzMaterial,nil)
	gg:AddCard(c)
	if gg:IsExists(Auxiliary.TuneMagXyzFilter,1,nil,gg,tp) then return false end
	return ct+1<=max
end
function Auxiliary.XyzCondition(f,lv,minc,maxc,mustbemat)
	--og: use special material
	return	function(e,c,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local xg=nil
				if tp==0 then
					xg=xyztempg0
				else
					xg=xyztempg1
				end
				if not xg or xg:GetCount()==0 then return false end
				local ft=Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)
				local ct=-ft
				local mg
				local sg=false
				if og then
					mg=og:Filter(Auxiliary.XyzM12,nil,f,lv,c,xg,mustbemat,tp)
					sg=mg:Clone()
					if not mustbemat then
						local mg2=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ONFIELD,0,nil,511002116)
						mg:Merge(mg2)
					end
				else
					mg=Duel.GetMatchingGroup(Auxiliary.XyzMatFilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,f,lv,c,tp)
					local mg2=Duel.GetMatchingGroup(Auxiliary.XyzSubMatFilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,f,lv,c,xg,mustbemat)
					mg:Merge(mg2)
				end
				local minc=minc
				local maxc=maxc
				if ct>=minc then return false end
				local minchk=min
				if c:GetFlagEffect(999)~=0 then minchk=nil end
				return mg:IsExists(Auxiliary.XyzFilterChk,1,nil,mg,c,tp,minc,maxc,nil,0,false,false,sg,minchk,0,mustbemat)
			end
end
function Auxiliary.XyzTarget(f,lv,minc,maxc,mustbemat)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
				if og and not min then
					if not og:IsExists(Auxiliary.XyzFilterChk,1,nil,og,c,tp,minc,maxc,nil,0,false,false,og,og:GetCount(),0,mustbemat) then
						local matg=Group.CreateGroup()
						local mg=og:Clone()
						if not mustbemat then
							local mg2=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ONFIELD,0,nil,511002116)
							mg:Merge(mg2)
						end
						local ct=og:GetCount()
						tog=og:Clone()
						local tc=tog:GetFirst()
						local matct=0
						local ct=0
						while tc do
							local isDouble=false
							if not mustbemat and tc:IsHasEffect(511001225) and (not tc.xyzlimit2 or tc.xyzlimit2(c)) and ct+1<minc
								and (not Auxiliary.XyzFilterChk(tc,mg,c,tp,minc,maxc,matg,ct,true,true,og,og:GetCount(),matct,mustbemat) or Duel.SelectYesNo(tp,65)) then
								isDouble=true
							end
							if not mustbemat and tc:IsHasEffect(511003001) and (not tc.xyzlimit3 or tc.xyzlimit3(c)) and ct+2<minc then
								if (isDouble and not Auxiliary.XyzFilterChk(tc,mg,c,tp,minc,maxc,matg,ct,false,true,og,og:GetCount(),matct,mustbemat)) 
									or (not isDouble and not Auxiliary.XyzFilterChk(tc,mg,c,tp,minc,maxc,matg,ct,true,true,og,og:GetCount(),matct,mustbemat)) 
									or Duel.SelectYesNo(tp,65) then
									local tct=2
									if isDouble then tct=1 end
									ct=ct+tct
								end
							end
							ct=ct+1
							if isDouble then ct=ct+1 end
							matct=matct+1
							mg:RemoveCard(tc)
							matg:AddCard(tc)
							tc=tog:GetNext()
						end
						while ct<minc do
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
							local sg=mg:Select(tp,1,1,nil)
							ct=ct+1
							mg:Sub(sg)
							matg:Merge(sg)
						end
						if matg then
							matg:KeepAlive()
							e:SetLabelObject(matg)
							return true
						else return false end
					else
						if og then
							og:KeepAlive()
							e:SetLabelObject(og)
							return true
						else return false end
					end
				else
					local xg=nil
					if tp==0 then
						xg=xyztempg0
					else
						xg=xyztempg1
					end
					local mg
					local sg=false
					if og then
						mg=og:Filter(Auxiliary.XyzM12,nil,f,lv,c,xg,mustbemat,tp)
						sg=mg:Clone()
						if not mustbemat then
							local mg2=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ONFIELD,0,nil,511002116)
							mg:Merge(mg2)
						end
					else
						mg=Duel.GetMatchingGroup(Auxiliary.XyzM12,tp,LOCATION_MZONE,LOCATION_MZONE,nil,f,lv,c,xg,mustbemat,tp)
						local mg2=Duel.GetMatchingGroup(Auxiliary.XyzSubMatFilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,f,lv,c,xg,mustbemat)
						mg:Merge(mg2)
					end
					local ct=0
					local minc=minc
					local maxc=maxc
					local min=min
					if min==-1 then min=1 end
					if min then
						if min>minc then minc=min end
						if max<maxc then maxc=max end
					end
					local matg=Group.CreateGroup()
					while ct<minc or not matg:IsExists(Auxiliary.XyzFCheck,1,nil,tp) or matg:IsExists(Auxiliary.XyzMatNumCheck,1,nil,matg:GetCount()) do
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
						local g=mg:FilterSelect(tp,Auxiliary.XyzFilterChk,1,1,nil,mg,c,tp,minc,maxc,matg,ct,false,false,sg,nil,nil,mustbemat)
						local tc=g:GetFirst()
						local isDouble=false
						if not mustbemat and tc:IsHasEffect(511001225) and (not tc.xyzlimit2 or tc.xyzlimit2(c)) and ct+1<minc 
							and (not Auxiliary.XyzFilterChk(tc,mg,c,tp,minc,maxc,matg,ct,true,true,sg,nil,nil,mustbemat) or Duel.SelectYesNo(tp,65)) then
							isDouble=true
						end
						if not mustbemat and tc:IsHasEffect(511003001) and (not tc.xyzlimit3 or tc.xyzlimit3(c)) and ct+2<minc then
							if (isDouble and not Auxiliary.XyzFilterChk(tc,mg,c,tp,minc,maxc,matg,ct,false,true,sg,nil,nil,mustbemat)) 
								or (not isDouble and not Auxiliary.XyzFilterChk(tc,mg,c,tp,minc,maxc,matg,ct,true,true,sg,nil,nil,mustbemat)) 
								or Duel.SelectYesNo(tp,65) then
								local tct=2
								if isDouble then tct=1 end
								ct=ct+tct
							end
						end
						if isDouble then ct=ct+1 end
						if not mustbemat then
							local eqg=tc:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175)
							mg:Merge(eqg)
						end
						mg:RemoveCard(tc)
						matg:AddCard(tc)
						ct=ct+1
					end
					if ct<maxc then
						while mg:IsExists(Auxiliary.ExtraXyzMaterial,1,nil,matg,tp,ct,maxc) and Duel.SelectYesNo(tp,513) do
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
							local g=mg:FilterSelect(tp,Auxiliary.ExtraXyzMaterial,1,1,nil,matg,tp,ct,maxc)
							local tc=g:GetFirst()
							if not mustbemat then
								local eqg=tc:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175)
								mg:Merge(eqg)
							end
							mg:RemoveCard(tc)
							matg:AddCard(tc)
							ct=ct+1
						end
					end
					if matg then
						matg:KeepAlive()
						e:SetLabelObject(matg)
						return true
					else return false end
				end
			end
end	
function Auxiliary.XyzOperation(f,lv,minc,maxc,mustbemat)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
				local g=e:GetLabelObject()
				local remg=g:Filter(Card.IsHasEffect,nil,511002116)
				local tc=remg:GetFirst()
				while tc do
					tc:RegisterFlagEffect(511002115,RESET_EVENT+0x1fe0000,0,0)
					tc=remg:GetNext()
				end
				g:Remove(Card.IsHasEffect,nil,511002116)
				g:Remove(Card.IsHasEffect,nil,511002115)
				local sg=Group.CreateGroup()
				tc=g:GetFirst()
				while tc do
					local sg1=tc:GetOverlayGroup()
					sg:Merge(sg1)
					tc=g:GetNext()
				end
				Duel.SendtoGrave(sg,REASON_RULE)
				c:SetMaterial(g)
				Duel.Overlay(c,g:Filter(function(c) return c:GetEquipTarget() end,nil))
				Duel.Overlay(c,g)
				g:DeleteGroup()
			end
end
--Xyz summon(alterf)
function Auxiliary.XyzCondition2(alterf,op)
	return	function(e,c,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local ct=-ft
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
				end
				return ct<1 and (not min or min<=1) and mg:IsExists(Auxiliary.XyzAlterFilter,1,nil,alterf,c,tp)
					and (not op or op(e,tp,0))
			end
end
function Auxiliary.XyzTarget2(alterf,op)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
				if op then op(e,tp,1) end
				if og and not min then
					og:KeepAlive()
					e:SetLabelObject(og)
					return true
				else
					local mg=nil
					if og then
						mg=og
					else
						mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
					end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local g=mg:FilterSelect(tp,Auxiliary.XyzAlterFilter,1,1,nil,alterf,c,tp)
					if g then
						g:KeepAlive()
						e:SetLabelObject(g)
						return true
					else return false end
				end
			end
end	
function Auxiliary.XyzOperation2(alterf,op)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
				local g=e:GetLabelObject()
				local mg2=g:GetFirst():GetOverlayGroup()
				if mg2:GetCount()~=0 then
					Duel.Overlay(c,mg2)
				end
				c:SetMaterial(g)
				Duel.Overlay(c,g)
				g:DeleteGroup()
			end
end
function Auxiliary.FConditionCheckF(c,chkf)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(chkf)
end
--Fusion monster, name + name
--material_count: number of different names in material list
--material: names in material list
function Auxiliary.AddFusionProcCode2(c,code1,code2,sub,insf)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	if c.material_count==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.material_count=2
		mt.material={code1,code2}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FConditionCode2(code1,code2,sub,insf))
	e1:SetOperation(Auxiliary.FOperationCode2(code1,code2,sub,insf))
	c:RegisterEffect(e1)
end
function Auxiliary.FFilterCodeOrSub(c,code1,code2,code3,code4,sub,fc)
	return c:IsFusionCode(code1,code2,code3,code4) or (sub and c:CheckFusionSubstitute(fc))
end
function Auxiliary.FConditionFilter21(c,code1,code2,sub,fc,mg,chkf,tp)
	return mg:IsExists(Auxiliary.FConditionFilter22,1,c,code1,code2,sub,fc,c,chkf,tp)
end
function Auxiliary.FConditionFilter21Tune(c,code1,code2,sub,fc,mg,chkf,tp,gc)
	if not c:IsHasEffect(73941492) or not c.fuslimitfilter then return false end
	if gc then
		if gc==c then
			return mg:IsExists(Auxiliary.FConditionFilter22,1,c,code1,code2,sub,fc,c,chkf,tp)
		else
			return Auxiliary.FConditionFilter22(gc,code1,code2,sub,fc,c,chkf,tp)
		end
		
	else
		return mg:IsExists(Auxiliary.FConditionFilter22,1,c,code1,code2,sub,fc,c,chkf,tp)
	end
end
function Auxiliary.FConditionFilter22(c,code1,code2,sub,fc,c2,chkf,tp)
	local g=Group.FromCards(c,c2)
	if g:IsExists(Auxiliary.TuneMagFusFilter,1,nil,g,tp) then return false end
	local b1=0 local b2=0 local bw=0 local bwxct=0
	local ct=0
	local fs=chkf==PLAYER_NONE
	local tc=g:GetFirst()
	while tc do
		local match=false
		if tc:IsFusionCode(code1) then b1=1 match=true end
		if tc:IsFusionCode(code2) then b2=1 match=true end
		--511002961 - Anime Parasite Fusioner
		if sub and tc:IsHasEffect(511002961) then bwxct=bwxct+1 match=true end
		if sub and not tc:IsHasEffect(511002961) and tc:CheckFusionSubstitute(fc) then bw=1 match=true end
		if match then
			if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
			ct=ct+1
		end
		tc=g:GetNext()
	end
	return ct>1 and b1+b2+bw+bwxct>1 and fs
end
function Auxiliary.FConditionCode2(code1,code2,sub,insf)
	--g:Material group(nil for Instant Fusion)
	--gc:Material already used
	--chkf: check field, default:PLAYER_NONE
	return	function(e,g,gc,chkfnf)
				local c=e:GetHandler()
				if c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() then return false end
				if g==nil then return insf end
				local tp=c:GetControler() --not yet needed
				local chkf=bit.band(chkfnf,0xff)
				local notfusion=bit.rshift(chkfnf,8)~=0
				local sub=sub or notfusion
				local mg=g:Filter(Card.IsCanBeFusionMaterial,gc,e:GetHandler())
				mg=mg:Filter(Auxiliary.FFilterCodeOrSub,gc,code1,code2,nil,nil,sub,e:GetHandler())
				local mg1=mg:Filter(function(c) return not c:IsHasEffect(73941492) or not c.fuslimitfilter end,nil)
				if gc then
					if not gc:IsCanBeFusionMaterial(e:GetHandler()) 
						or not Auxiliary.FFilterCodeOrSub(gc,code1,code2,nil,nil,sub,e:GetHandler()) then return false end
					local b1=0 local b2=0 local bw=0 local bwx=0
					if gc:IsFusionCode(code1) then b1=1 end
					if gc:IsFusionCode(code2) then b2=1 end
					if sub and gc:IsHasEffect(511002961) then bwx=1 end
					if sub and gc:CheckFusionSubstitute(e:GetHandler()) then bw=1 end
					if b1+b2+bw>0 then
						if chkf~=PLAYER_NONE and not Auxiliary.FConditionCheckF(gc,chkf) then
							mg1=mg1:Filter(Auxiliary.FConditionCheckF,nil,chkf)
						end	
						if b1+b2+bw>1 or bwx==1 then
							if mg1:IsExists(Auxiliary.FFilterCodeOrSub,1,gc,code1,code2,nil,nil,sub,e:GetHandler()) then return true end
						elseif b1==1 then
							if mg1:IsExists(Auxiliary.FFilterCodeOrSub,1,gc,code2,nil,nil,nil,sub,e:GetHandler()) then return true end
						elseif b2==1 then
							if mg1:IsExists(Auxiliary.FFilterCodeOrSub,1,gc,code1,nil,nil,nil,sub,e:GetHandler()) then return true end
						else
							if mg1:IsExists(function(c) return c:IsFusionCode(code1,code2) or (sub and c:IsHasEffect(511002961)) end,1,gc) then return true end
						end
					end
					return mg:IsExists(Auxiliary.FConditionFilter21Tune,1,nil,code1,code2,sub,e:GetHandler(),mg,chkf,tp,gc)
				end
				local b1=0 local b2=0 local bw=0 local bwxct=0
				local ct=0
				local fs=chkf==PLAYER_NONE
				local tc=mg1:GetFirst()
				while tc do
					local match=false
					if tc:IsFusionCode(code1) then b1=1 match=true end
					if tc:IsFusionCode(code2) then b2=1 match=true end
					if sub and tc:IsHasEffect(511002961) then bwxct=bwxct+1 match=true end
					if sub and not tc:IsHasEffect(511002961) and tc:CheckFusionSubstitute(e:GetHandler()) then bw=1 match=true end
					if match then
						if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
						ct=ct+1
					end
					tc=mg1:GetNext()
				end
				if ct>1 and b1+b2+bw+bwxct>1 and fs then return true end
				return mg:IsExists(Auxiliary.FConditionFilter21Tune,1,nil,code1,code2,sub,e:GetHandler(),mg,chkf,tp,nil)
			end
end
function Auxiliary.FOperationCode2(code1,code2,sub,insf)
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=bit.band(chkfnf,0xff)
				local notfusion=bit.rshift(chkfnf,8)~=0
				local sub=sub or notfusion
				local g=eg:Filter(Card.IsCanBeFusionMaterial,gc,e:GetHandler())
				g=g:Filter(Auxiliary.FFilterCodeOrSub,gc,code1,code2,nil,nil,sub,e:GetHandler())
				local mg1=g:Filter(function(c) return not c:IsHasEffect(73941492) or not c.fuslimitfilter end,nil)
				local tc=gc
				local g1=nil
				local p=tp
				local sfhchk=false
				--511004008 - Spiritual Fusion
				if Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp Duel.ConfirmCards(1-tp,g)
					if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				if not gc then
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					g1=g:FilterSelect(p,Auxiliary.FConditionFilter21,1,1,nil,code1,code2,sub,e:GetHandler(),g,chkf,tp)
					tc=g1:GetFirst()
					g:RemoveCard(tc)
				end
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
				local g2=g:FilterSelect(p,Auxiliary.FConditionFilter22,1,1,tc,code1,code2,sub,e:GetHandler(),tc,chkf,tp)
				if g1 then g2:Merge(g1) end
				if sfhchk then Duel.ShuffleHand(tp) end
				Duel.SetFusionMaterial(g2)
			end
end
--Fusion monster, name + name + name
function Auxiliary.AddFusionProcCode3(c,code1,code2,code3,sub,insf)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	if c.material_count==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.material_count=3
		mt.material={code1,code2,code3}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FConditionCode3(code1,code2,code3,sub,insf))
	e1:SetOperation(Auxiliary.FOperationCode3(code1,code2,code3,sub,insf))
	c:RegisterEffect(e1)
end
function Auxiliary.FConditionFilter31(c,code1,code2,code3,sub,fc,mg,g2,chkf,ct,tp)
	local tg
	if g2==nil or g2:GetCount()==0 then tg=Group.CreateGroup() else tg=g2:Clone() end
	local g=mg:Clone()
	local ctc=ct+1
	tg:AddCard(c)
	g:RemoveCard(c)
	if ctc==3 then
		return Auxiliary.FConditionFilter3Chk(tg,code1,code2,code3,sub,fc,chkf,tp)
	else
		return g:IsExists(Auxiliary.FConditionFilter31,1,nil,code1,code2,code3,sub,fc,g,tg,chkf,ctc,tp)
	end
end
function Auxiliary.FConditionFilter3Tune(c,code1,code2,code3,sub,fc,mg,g2,chkf,ct,tp,gc)
	local tg
	if g2==nil or g2:GetCount()==0 then tg=Group.CreateGroup() else tg=g2:Clone() end
	local g=mg:Clone()
	local ctc=ct+1
	tg:AddCard(c)
	g:RemoveCard(c)
	if not c:IsHasEffect(73941492) or not c.fuslimitfilter then return false end
	if gc then
		if gc==c then
			return g:IsExists(Auxiliary.FConditionFilter31,1,nil,code1,code2,code3,sub,fc,g,tg,chkf,ctc,tp)
		else
			Auxiliary.FConditionFilter31(gc,code1,code2,code3,sub,fc,g,tg,chkf,ctc,tp)
		end
	else
		return g:IsExists(Auxiliary.FConditionFilter31,1,nil,code1,code2,code3,sub,fc,g,tg,chkf,ctc,tp)
	end
end
function Auxiliary.FConditionFilterCodeAndSub(c,code,fc)
	return c:IsFusionCode(code) and c:CheckFusionSubstitute(fc)
end
function Auxiliary.FConditionFilter3Chk(g,code1,code2,code3,sub,fc,chkf,tp)
	if g:IsExists(Auxiliary.TuneMagFusFilter,1,nil,g,tp) then return false end
	local b1=0 local b2=0 local b3=0 local bs=0 local bwxct=0 local bwg=Group.CreateGroup()
	local fs=false
	local tc=g:GetFirst()
	while tc do
		if sub and tc:IsHasEffect(511002961) then
			bwxct=bwxct+1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
		else
			if bwg:IsExists(Auxiliary.FConditionFilterCodeAndSub,1,nil,tc:GetCode(),fc) then
				if tc:IsFusionCode(code1) then b1=1 elseif tc:IsFusionCode(code2) then b2=1 
					elseif tc:IsFusionCode(code3) then b3=1 
				end
				bs=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
				bwg:Remove(Auxiliary.FConditionFilterCodeAndSub,nil,tc:GetCode(),fc)
			else
				if sub and tc:CheckFusionSubstitute(fc) then
					if tc:IsFusionCode(code1,code2,code3) then bwg:AddCard(tc) 
					else bs=1 end
					if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
				else
					if tc:IsFusionCode(code1) then b1=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
					elseif tc:IsFusionCode(code2) then b2=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
					elseif tc:IsFusionCode(code3) then b3=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
					end
				end
			end
		end
		tc=g:GetNext()
	end
	local chc=bwg:GetFirst()
	while chc do
		if tc:IsFusionCode(code1) and b1==0 then b1=1
		elseif tc:IsFusionCode(code2) and b2==0 then b2=1
		elseif tc:IsFusionCode(code3) and b3==0 then b3=1
		else bs=1 end
		chc=bwg:GetNext()
	end
	return b1+b2+b3+bs+bwxct>=3 and (fs or chkf==PLAYER_NONE)
end
function Auxiliary.TuneMagFusFilter(c,g,tp)
	return c:IsHasEffect(73941492) and c.fuslimitfilter and g:IsExists(Auxiliary.TuneMagFilter2,1,c,c.fuslimitfilter,tp)
end
function Auxiliary.FConditionCode3(code1,code2,code3,sub,insf)
	return	function(e,g,gc,chkfnf)
				local c=e:GetHandler()
				if c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() then return false end
				if g==nil then return insf end
				local chkf=bit.band(chkfnf,0xff)
				local notfusion=bit.rshift(chkfnf,8)~=0
				local sub=sub or notfusion
				local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
				mg=mg:Filter(Auxiliary.FFilterCodeOrSub,gc,code1,code2,code3,nil,sub,e:GetHandler())
				local mg1=mg:Filter(function(c) return not c:IsHasEffect(73941492) or not c.fuslimitfilter end,nil)
				if gc then
					if not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
					local b1=0 local b2=0 local b3=0 local bw=0 local bwxct=0 local bwg=Group.CreateGroup()
					local tc=mg1:GetFirst()
					while tc do
						if sub and tc:IsHasEffect(511002961) then
							bwxct=bwxct+1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
						else
							if bwg:IsExists(Auxiliary.FConditionFilterCodeAndSub,1,nil,tc:GetCode(),e:GetHandler()) then
								if tc:IsFusionCode(code1) then b1=1 elseif tc:IsFusionCode(code2) then b2=1 
									elseif tc:IsFusionCode(code3) then b3=1 
								end
								bw=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
								bwg:Remove(Auxiliary.FConditionFilterCodeAndSub,nil,tc:GetCode(),e:GetHandler())
							else
								if sub and tc:CheckFusionSubstitute(e:GetHandler()) then
									if tc:IsFusionCode(code1,code2,code3) then bwg:AddCard(tc) 
									else bw=1 end
									if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
								else
									if tc:IsFusionCode(code1) then b1=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
									elseif tc:IsFusionCode(code2) then b2=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
									elseif tc:IsFusionCode(code3) then b3=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
									end
								end
							end
						end
						tc=mg1:GetNext()
					end
					local chc=bwg:GetFirst()
					while chc do
						if tc:IsFusionCode(code1) and b1==0 then b1=1
						elseif tc:IsFusionCode(code2) and b2==0 then b2=1
						elseif tc:IsFusionCode(code3) and b3==0 then b3=1
						else bw=1 end
						chc=bwg:GetNext()
					end
					if sub and gc:IsHasEffect(511002961) then
						if b1+b2+b3+bw+bwxct>1 then return true end
					elseif sub and gc:CheckFusionSubstitute(e:GetHandler()) then
						if b1+b2+b3+bwxct>1 then return true end
					else
						local fail=false
						if gc:IsFusionCode(code1) and b1==0 then b1=1
						elseif gc:IsFusionCode(code2) and b2==0 then b2=1
						elseif gc:IsFusionCode(code3) and b3==0 then b3=1
						else fail=true
						end
						if not fail and b1+b2+b3+bw+bwxct>2 then return true end
					end
					return mg:IsExists(Auxiliary.FConditionFilter3Tune,1,nil,code1,code2,code3,sub,e:GetHandler(),mg,nil,chkf,0,tp,gc)
				end
				local b1=0 local b2=0 local b3=0 local bs=0 local bwxct=0 local bwg=Group.CreateGroup()
				local fs=false
				local tc=mg1:GetFirst()
				while tc do
					if sub and tc:IsHasEffect(511002961) then
						bwxct=bwxct+1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
					else
						if bwg:IsExists(Auxiliary.FConditionFilterCodeAndSub,1,nil,tc:GetCode(),e:GetHandler()) then
							if tc:IsFusionCode(code1) then b1=1 elseif tc:IsFusionCode(code2) then b2=1 
								elseif tc:IsFusionCode(code3) then b3=1 
							end
							bs=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
							bwg:Remove(c511002961.FConditionFilterCodeAndSub,nil,tc:GetCode(),e:GetHandler())
						else
							if sub and tc:CheckFusionSubstitute(e:GetHandler()) then
								if tc:IsFusionCode(code1,code2,code3) then bwg:AddCard(tc) 
								else bs=1 end
								if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
							else
								if tc:IsFusionCode(code1) then b1=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
								elseif tc:IsFusionCode(code2) then b2=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
								elseif tc:IsFusionCode(code3) then b3=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
								end
							end
						end
					end
					tc=mg1:GetNext()
				end
				local chc=bwg:GetFirst()
				while chc do
					if tc:IsFusionCode(code1) and b1==0 then b1=1
					elseif tc:IsFusionCode(code2) and b2==0 then b2=1
					elseif tc:IsFusionCode(code3) and b3==0 then b3=1
					else bs=1 end
					chc=bwg:GetNext()
				end
				if b1+b2+b3+bs+bwxct>=3 and (fs or chkf==PLAYER_NONE) then return true end
				return mg:IsExists(Auxiliary.FConditionFilter3Tune,1,nil,code1,code2,code3,sub,e:GetHandler(),mg,nil,chkf,0,tp)
			end
end
function Auxiliary.FConditionFilterx(c,fc,code1,code2,code3,code4)
	return c:CheckFusionSubstitute(fc) and not c:IsHasEffect(511002961) and not c:IsFusionCode(code1,code2,code3,code4)
end
function Auxiliary.FOperationCode3(code1,code2,code3,sub,insf)
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=bit.band(chkfnf,0xff)
				local notfusion=bit.rshift(chkfnf,8)~=0
				local sub=sub or notfusion
				local g=eg:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
				g=g:Filter(Auxiliary.FFilterCodeOrSub,gc,code1,code2,code3,nil,sub,e:GetHandler())
				local mg1=g:Filter(function(c) return not c:IsHasEffect(73941492) or not c.fuslimitfilter end,nil)
				local p=tp
				local sfhchk=false
				if Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp Duel.ConfirmCards(1-tp,g)
					if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				if gc then
					local matg=Group.CreateGroup()
					g:RemoveCard(gc)
					matg:AddCard(gc)
					for i=1,2 do
						Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
						local g1=g:FilterSelect(p,Auxiliary.FConditionFilter31,1,1,nil,code1,code2,code3,sub,e:GetHandler(),g,matg,chkf,i,tp)
						matg:Merge(g1)
						g:Sub(g1)
					end
					matg:RemoveCard(gc)
					if sfhchk then Duel.ShuffleHand(tp) end
					Duel.SetFusionMaterial(matg)
					return
				end
				local matg=Group.CreateGroup()
				for i=1,3 do
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					local g1=g:FilterSelect(p,Auxiliary.FConditionFilter31,1,1,nil,code1,code2,code3,sub,e:GetHandler(),g,matg,chkf,i-1,tp)
					matg:Merge(g1)
					g:Sub(g1)
				end
				if sfhchk then Duel.ShuffleHand(tp) end
				Duel.SetFusionMaterial(matg)
			end
end
--Fusion monster, name + name + name + name
function Auxiliary.AddFusionProcCode4(c,code1,code2,code3,code4,sub,insf)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	if c.material_count==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.material_count=4
		mt.material={code1,code2,code3,code4}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FConditionCode4(code1,code2,code3,code4,sub,insf))
	e1:SetOperation(Auxiliary.FOperationCode4(code1,code2,code3,code4,sub,insf))
	c:RegisterEffect(e1)
end
function Auxiliary.FConditionFilter41(c,code1,code2,code3,code4,sub,fc,chkf,mg,g2,ct)
	local tg
	local g
	if g2==nil or g2:GetCount()==0 then tg=Group.CreateGroup() else tg=g2:Clone() end
	tg:AddCard(c)
	g=mg:Clone()
	g:RemoveCard(c)
	ct=ct+1
	if ct==4 then
		return Auxiliary.FConditionFilter42(code1,code2,code3,code4,sub,fc,chkf,tg)
	else
		return g:IsExists(Auxiliary.FConditionFilter41,1,c,code1,code2,code3,code4,sub,fc,chkf,g,tg,ct)
	end
end
function Auxiliary.FConditionFilter42(code1,code2,code3,code4,sub,fc,chkf,g)
	if g:IsExists(Auxiliary.TuneMagFusFilter,1,nil,g,chkf) then return false end
	local b1=0 local b2=0 local b3=0 local b4=0 local bs=0 local bwxct=0 local bwg=Group.CreateGroup()
	local fs=false
	local tc=g:GetFirst()
	while tc do
		if sub and tc:IsHasEffect(511002961) then
			bwxct=bwxct+1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
		else
			if bwg:IsExists(Auxiliary.FConditionFilterCodeAndSub,1,nil,tc:GetCode(),fc) then
				if tc:IsFusionCode(code1) then b1=1 elseif tc:IsFusionCode(code2) then b2=1 
					elseif tc:IsFusionCode(code3) then b3=1 elseif tc:IsFusionCode(code4) then b4=1 
				end
				bs=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
				bwg:Remove(Auxiliary.FConditionFilterCodeAndSub,nil,tc:GetCode(),fc)
			else
				if sub and tc:CheckFusionSubstitute(fc) then
					if tc:IsFusionCode(code1,code2,code3,code4) then bwg:AddCard(tc) 
					else bs=1 end
					if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
				else
					if tc:IsFusionCode(code1) then b1=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
					elseif tc:IsFusionCode(code2) then b2=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
					elseif tc:IsFusionCode(code3) then b3=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
					elseif tc:IsFusionCode(code4) then b4=1 if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
					end
				end
			end
		end
		tc=g:GetNext()
	end
	local chc=bwg:GetFirst()
	while chc do
		if tc:IsFusionCode(code1) and b1==0 then b1=1
		elseif tc:IsFusionCode(code2) and b2==0 then b2=1
		elseif tc:IsFusionCode(code3) and b3==0 then b3=1
		elseif tc:IsFusionCode(code4) and b4==0 then b4=1
		else bs=1 end
		chc=bwg:GetNext()
	end
	return b1+b2+b3+b4+bs+bwxct>=4 and (fs or chkf==PLAYER_NONE)
end
function Auxiliary.FConditionCode4(code1,code2,code3,code4,sub,insf)
	return	function(e,g,gc,chkfnf)
				local c=e:GetHandler()
				if c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() then return false end
				if g==nil then return insf end
				local chkf=bit.band(chkfnf,0xff)
				local notfusion=bit.rshift(chkfnf,8)~=0
				local sub=sub or notfusion
				local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
				mg=mg:Filter(Auxiliary.FFilterCodeOrSub,gc,code1,code2,code3,code4,sub,e:GetHandler())
				if gc then
					if not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
					return Auxiliary.FConditionFilter41(gc,code1,code2,code3,code4,sub,e:GetHandler(),chkf,mg,nil,0)
				end
				return mg:IsExists(Auxiliary.FConditionFilter41,1,nil,code1,code2,code3,code4,sub,e:GetHandler(),chkf,mg,nil,0)
			end
end
function Auxiliary.FOperationCode4(code1,code2,code3,code4,sub,insf)
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=bit.band(chkfnf,0xff)
				local notfusion=bit.rshift(chkfnf,8)~=0
				local sub=sub or notfusion
				local g=eg:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
				g=g:Filter(Auxiliary.FFilterCodeOrSub,gc,code1,code2,code3,code4,sub,e:GetHandler())
				local p=tp
				local sfhchk=false
				if Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp Duel.ConfirmCards(1-tp,g)
					if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				if gc then
					local matg=Group.CreateGroup()
					matg:AddCard(gc)
					for i=1,3 do
						Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
						local g1=g:FilterSelect(p,Auxiliary.FConditionFilter41,1,1,nil,code1,code2,code3,code4,sub,e:GetHandler(),chkf,g,matg,i)
						matg:Merge(g1)
						g:Sub(g1)
					end
					matg:RemoveCard(gc)
					if sfhchk then Duel.ShuffleHand(tp) end
					Duel.SetFusionMaterial(matg)
					return
				end
				local matg=Group.CreateGroup()
				for i=1,4 do
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					local g1=g:FilterSelect(p,Auxiliary.FConditionFilter41,1,1,nil,code1,code2,code3,code4,sub,e:GetHandler(),chkf,g,matg,i-1)
					matg:Merge(g1)
					g:Sub(g1)
				end
				if sfhchk then Duel.ShuffleHand(tp) end
				Duel.SetFusionMaterial(matg)
			end
end
--Fusion monster, name + condition
function Auxiliary.AddFusionProcCodeFun(c,code1,f,cc,sub,insf)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	if c.material_count==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.material_count=1
		mt.material={code1}
	end
	local f=function(c) return f(c) and not c:IsHasEffect(6205579) end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FConditionCodeFun(code1,f,cc,sub,insf))
	e1:SetOperation(Auxiliary.FOperationCodeFun(code1,f,cc,sub,insf))
	c:RegisterEffect(e1)
end
function Auxiliary.FConditionFilterCF1(c,code,f,cc,sub,fc,chkf,mg,g2,ct,gc)
	local tg=Group.CreateGroup()
	local g=mg:Clone()
	tg:AddCard(c)
	g:RemoveCard(c)
	return g:IsExists(Auxiliary.FConditionFilterCF2,1,c,code,f,cc,sub,fc,chkf,g,tg,ct,gc)
end
function Auxiliary.FConditionFilterCF2(c,code,f,cc,sub,fc,chkf,mg,g2,ct,gc)
	local tg=g2:Clone()
	local g=mg:Clone()
	local ctc=ct+1
	if gc then
		tg:AddCard(gc)
		g:RemoveCard(gc)
	else
		tg:AddCard(c)
		g:RemoveCard(c)
	end
	if ctc==cc then
		return Auxiliary.FConditionFilterCF3(code,f,cc,sub,fc,chkf,tg)
	else
		return g:IsExists(Auxiliary.FConditionFilterCF2,1,nil,code,f,cc,sub,fc,chkf,g,tg,ctc,nil)
	end
end
function Auxiliary.FConditionFilterCF3(code,f,cc,sub,fc,chkf,g)
	if g:IsExists(Auxiliary.TuneMagFusFilter,1,nil,g,chkf) then return false end
	local b1=0 local b2=0 local bw=0
	local fs=false
	local tc=g:GetFirst()
	while tc do
		local c1=tc:IsFusionCode(code) or (sub and tc:CheckFusionSubstitute(fc))
		local c2=f(tc) or (sub and tc:IsHasEffect(511002961))
		if c1 or c2 then
			if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
			if c1 and c2 then bw=bw+1
			elseif c1 then b1=1
			else b2=b2+1
			end
		end
		tc=g:GetNext()
	end
	if b2>cc then b2=cc end
	return b1+b2+bw>=1+cc and (fs or chkf==PLAYER_NONE)
end
function Auxiliary.FConditionCodeFun(code,f,cc,sub,insf)
	return	function(e,g,gc,chkfnf)
				local c=e:GetHandler()
				if c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() then return false end
				if g==nil then return insf end
				local chkf=bit.band(chkfnf,0xff)
				local notfusion=bit.rshift(chkfnf,8)~=0
				local sub=sub or notfusion
				local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
				local mg1=mg:Filter(Auxiliary.FConditionFilterCR,nil,code,sub,e:GetHandler())
				if gc then
					if not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
					return Auxiliary.FConditionFilterCF1(gc,code,f,cc,sub,e:GetHandler(),chkf,mg,nil,0,nil) 
						or mg1:IsExists(Auxiliary.FConditionFilterCF1,1,nil,code,f,cc,sub,e:GetHandler(),chkf,mg,nil,0,gc)
				end
				return mg1:IsExists(Auxiliary.FConditionFilterCF1,1,nil,code,f,cc,sub,e:GetHandler(),chkf,mg,nil,0,nil)
			end
end
function Auxiliary.FOperationCodeFun(code,f,cc,sub,insf)
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=bit.band(chkfnf,0xff)
				local notfusion=bit.rshift(chkfnf,8)~=0
				local sub=sub or notfusion
				local g=eg:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
				local mg1=g:Filter(Auxiliary.FConditionFilterCR,nil,code,sub,e:GetHandler())
				local p=tp
				local sfhchk=false
				if Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp Duel.ConfirmCards(1-tp,g)
					if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				if gc then
					if Auxiliary.FConditionFilterCF1(gc,code,f,cc,sub,e:GetHandler(),chkf,g,nil,0,nil) then
						local matg=Group.FromCards(gc)
						local ct=0
						for i=1,cc do
							Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
							local g1=g:FilterSelect(p,Auxiliary.FConditionFilterCF2,1,1,nil,code,f,cc,sub,e:GetHandler(),chkf,g,matg,ct)
							ct=ct+1
							matg:Merge(g1)
							g:Sub(g1)
						end
						matg:RemoveCard(gc)
						if sfhchk then Duel.ShuffleHand(tp) end
						Duel.SetFusionMaterial(matg)
					else
						local ct=0
						local mc=gc
						Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
						local matg=mg1:FilterSelect(p,Auxiliary.FConditionFilterCF1,1,1,nil,code,f,cc,sub,e:GetHandler(),chkf,g,nil,ct,mc)
						matg:AddCard(mc)
						g:Sub(matg)
						mc=nil
						ct=ct+1
						if cc>ct then
							for i=1,cc-1 do
								Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
								local g1=g:FilterSelect(p,Auxiliary.FConditionFilterCF2,1,1,nil,code,f,cc,sub,e:GetHandler(),chkf,g,matg,ct)
								ct=ct+1
								matg:Merge(g1)
								g:Sub(g1)
							end
						end
						matg:RemoveCard(gc)
						if sfhchk then Duel.ShuffleHand(tp) end
						Duel.SetFusionMaterial(matg)
					end
					return
				end
				local ct=0
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
				local matg=mg1:FilterSelect(p,Auxiliary.FConditionFilterCF1,1,1,nil,code,f,cc,sub,e:GetHandler(),chkf,g,nil,ct)
				g:Sub(matg)
				for i=1,cc do
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					local g1=g:FilterSelect(p,Auxiliary.FConditionFilterCF2,1,1,nil,code,f,cc,sub,e:GetHandler(),chkf,g,matg,ct)
					ct=ct+1
					matg:Merge(g1)
					g:Sub(g1)
				end
				if sfhchk then Duel.ShuffleHand(tp) end
				Duel.SetFusionMaterial(matg)
			end
end
--Fusion monster, condition + condition
function Auxiliary.AddFusionProcFun2(c,f1,f2,insf)
	local f1=function(c) return f1(c) and not c:IsHasEffect(6205579) end
	local f2=function(c) return f2(c) and not c:IsHasEffect(6205579) end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FConditionFun2(f1,f2,insf))
	e1:SetOperation(Auxiliary.FOperationFun2(f1,f2,insf))
	c:RegisterEffect(e1)
end
function Auxiliary.FConditionFilterF2c(c,g2)
	return g2:IsExists(aux.TRUE,1,c)
end
function Auxiliary.FConditionFilterF2(c,f1,f2,mg,chkf)
	return mg:IsExists(Auxiliary.FConditionFilterF2chk,1,c,f1,f2,c,chkf)
end
function Auxiliary.FConditionFilterF2chk(c,f1,f2,c2,chkf)
	local g=Group.FromCards(c,c2)
	if g:IsExists(Auxiliary.TuneMagFusFilter,1,nil,g,chkf) then return false end
	local g1=Group.CreateGroup() local g2=Group.CreateGroup() local fs=false
	local tc=g:GetFirst()
	while tc do
		if f1(tc) or tc:IsHasEffect(511002961) then g1:AddCard(tc) if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end end
		if f2(tc) or tc:IsHasEffect(511002961) then g2:AddCard(tc) if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end end
		tc=g:GetNext()
	end
	if chkf~=PLAYER_NONE then
		return fs and g1:IsExists(Auxiliary.FConditionFilterF2c,1,nil,g2)
	else return g1:IsExists(Auxiliary.FConditionFilterF2c,1,nil,g2) end
end
function Auxiliary.FConditionFun2(f1,f2,insf)
	return	function(e,g,gc,chkfnf)
				local c=e:GetHandler()
				if c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() then return false end
				if g==nil then return insf end
				local chkf=bit.band(chkfnf,0xff)
				local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
				if gc then
					if not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
					return Auxiliary.FConditionFilterF2(gc,f1,f2,mg,chkf)
				end
				return mg:IsExists(Auxiliary.FConditionFilterF2,1,nil,f1,f2,mg,chkf)
			end
end
function Auxiliary.FOperationFun2(f1,f2,insf)
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=bit.band(chkfnf,0xff)
				local g=eg:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
				local p=tp
				local sfhchk=false
				--511004008 - Spiritual Fusion
				if Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp Duel.ConfirmCards(1-tp,g)
					if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				if gc then
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					local g1=g:FilterSelect(p,Auxiliary.FConditionFilterF2chk,1,1,gc,f1,f2,gc,chkf)
					if sfhchk then Duel.ShuffleHand(tp) end
					Duel.SetFusionMaterial(g1)
					return
				end
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
				local g1=g:FilterSelect(p,Auxiliary.FConditionFilterF2,1,1,nil,f1,f2,g,chkf)
				local tc1=g1:GetFirst()
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
				local g2=g:FilterSelect(p,Auxiliary.FConditionFilterF2chk,1,1,tc1,f1,f2,tc1,chkf)
				g1:Merge(g2)
				if sfhchk then Duel.ShuffleHand(tp) end
				Duel.SetFusionMaterial(g1)
			end
end
--Fusion monster, name * n
function Auxiliary.AddFusionProcCodeRep(c,code1,cc,sub,insf)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	if c.material_count==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.material_count=1
		mt.material={code1}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FConditionCodeRep(code1,cc,sub,insf))
	e1:SetOperation(Auxiliary.FOperationCodeRep(code1,cc,sub,insf))
	c:RegisterEffect(e1)
end
function Auxiliary.FConditionFilterCR(c,code,sub,fc)
	return c:IsFusionCode(code) or (sub and c:CheckFusionSubstitute(fc))
end
function Auxiliary.FConditionFilterx2(c,fc,sub)
	return sub and c:CheckFusionSubstitute(fc) and not c:IsHasEffect(511002961)
end
function Auxiliary.FConditionFilterx3(c,fc,sub)
	return sub and c:CheckFusionSubstitute(fc) and c:IsHasEffect(511002961)
end
function Auxiliary.FConditionFilterCodeOrSub2(c,code1,code2)
	return c:IsFusionCode(code1,code2) or c:IsHasEffect(511002961)
end
function Auxiliary.FConditionFilterCodeNotSub(c,code,fc)
	return c:IsFusionCode(code) and not c:CheckFusionSubstitute(fc)
end
function Auxiliary.FConditionFilterCode(c,code,cc,sub,fc,chkf,mg,g2,ct)
	local tg
	if g2==nil or g2:GetCount()==0 then tg=Group.CreateGroup() else tg=g2:Clone() end
	local g=mg:Clone()
	local ctc=ct+1
	tg:AddCard(c)
	g:RemoveCard(c)
	if ctc==cc then
		return Auxiliary.FConditionFilterCodeChk(code,cc,sub,fc,chkf,tg)
	else
		return g:IsExists(Auxiliary.FConditionFilterCode,1,nil,code,cc,sub,fc,chkf,g,tg,ctc)
	end
end
function Auxiliary.FConditionFilterCodeChk(code,cc,sub,fc,chkf,g)
	if g:IsExists(Auxiliary.TuneMagFusFilter,1,nil,g,chkf) then return false end
	local g1=g:Filter(Card.IsFusionCode,nil,code)
	if not sub then
		if chkf~=PLAYER_NONE then return g1:GetCount()>=cc and g1:FilterCount(Auxiliary.FConditionCheckF,nil,chkf)~=0
		else return g1:GetCount()>=cc end
	end
	g1=g1:Filter(Auxiliary.FConditionFilterCodeNotSub,nil,code,fc)
	local g2=g:Filter(Auxiliary.FConditionFilterx2,nil,fc,sub)
	local g3=g:Filter(Auxiliary.FConditionFilterx3,nil,fc,sub)
	g1:Merge(g3)
	if chkf~=PLAYER_NONE then
		return (g1:FilterCount(Auxiliary.FConditionCheckF,nil,chkf)~=0 or g2:FilterCount(Auxiliary.FConditionCheckF,nil,chkf)~=0)
			and g1:GetCount()>=cc-1 and g1:GetCount()+g2:GetCount()>=cc
	else return g1:GetCount()>=cc-1 and g1:GetCount()+g2:GetCount()>=cc end
end
function Auxiliary.FConditionCodeRep(code,cc,sub,insf)
	return	function(e,g,gc,chkfnf)
				local c=e:GetHandler()
				if c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() then return false end
				if g==nil then return insf end
				local chkf=bit.band(chkfnf,0xff)
				local notfusion=bit.rshift(chkfnf,8)~=0
				local sub=sub or notfusion
				local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
				if gc then
					if not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
					return Auxiliary.FConditionFilterCode(gc,code,cc,sub,e:GetHandler(),chkf,mg,nil,0)
				end
				return mg:IsExists(Auxiliary.FConditionFilterCode,1,nil,code,cc,sub,e:GetHandler(),chkf,mg,nil,0)
			end
end
function Auxiliary.FOperationCodeRep(code,cc,sub,insf)
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=bit.band(chkfnf,0xff)
				local notfusion=bit.rshift(chkfnf,8)~=0
				local sub=sub or notfusion
				local g=eg:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
				local p=tp
				local sfhchk=false
				if Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp Duel.ConfirmCards(1-tp,g)
					if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				if gc then
					local matg=Group.CreateGroup()
					local ct=1
					if cc>1 then
						matg:AddCard(gc)
						for i=1,cc-1 do
							Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
							local g1=g:FilterSelect(p,Auxiliary.FConditionFilterCode,1,1,nil,code,cc,sub,e:GetHandler(),chkf,g,matg,ct)
							matg:Merge(g1)
							g:Sub(g1)
							ct=ct+1
						end
						matg:RemoveCard(gc)
					end
					if sfhchk then Duel.ShuffleHand(tp) end
					Duel.SetFusionMaterial(matg)
					return
				end
				local matg=Group.CreateGroup()
				local ct=0
				for i=1,cc do
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					local g1=g:FilterSelect(p,Auxiliary.FConditionFilterCode,1,1,nil,code,cc,sub,e:GetHandler(),chkf,g,matg,ct)
					matg:Merge(g1)
					g:Sub(g1)
					ct=ct+1
				end
				if sfhchk then Duel.ShuffleHand(tp) end
				Duel.SetFusionMaterial(matg)
			end
end
--Fusion monster, condition * n
function Auxiliary.AddFusionProcFunRep(c,f,cc,insf)
	local f=function(c) return f(c) and not c:IsHasEffect(6205579) end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FConditionFunRep(f,cc,insf))
	e1:SetOperation(Auxiliary.FOperationFunRep(f,cc,insf))
	c:RegisterEffect(e1)
end
function Auxiliary.FConditionFilterConAndSub(c,f,sub)
	return f(c) or (sub and c:IsHasEffect(511002961))
end
function Auxiliary.FConditionFilterConN(c,f,cc,fc,chkf,mg,g2,ct)
	local tg
	if g2==nil or g2:GetCount()==0 then tg=Group.CreateGroup() else tg=g2:Clone() end
	local g=mg:Clone()
	local ctc=ct+1
	tg:AddCard(c)
	g:RemoveCard(c)
	if ctc==cc then
		return Auxiliary.FConditionFilterConNChk(f,cc,fc,chkf,tg)
	else
		return g:IsExists(Auxiliary.FConditionFilterConN,1,nil,f,cc,fc,chkf,g,tg,ctc)
	end
end
function Auxiliary.FConditionFilterConNTune(c,f,cc,fc,chkf,mg,g2,ct,gc)
	local tg
	if g2==nil or g2:GetCount()==0 then tg=Group.CreateGroup() else tg=g2:Clone() end
	local g=mg:Clone()
	local ctc=ct+1
	if not c:IsHasEffect(73941492) or not c.fuslimitfilter then return false end
	tg:AddCard(c)
	g:RemoveCard(c)
	if gc then
		if gc==c then
			if ctc==cc then
				return Auxiliary.FConditionFilterConNChk(f,cc,fc,chkf,tg)
			else
				return g:IsExists(Auxiliary.FConditionFilterConN,1,nil,f,cc,fc,chkf,g,tg,ctc)
			end
		else
			if ctc==cc then
				return tg:IsContains(gc) and Auxiliary.FConditionFilterConNChk(f,cc,fc,chkf,tg)
			else
				return Auxiliary.FConditionFilterConN(gc,f,cc,fc,chkf,g,tg,ctc)
			end
		end
	else
		if ctc==cc then
			return Auxiliary.FConditionFilterConNChk(f,cc,fc,chkf,tg)
		else
			return g:IsExists(Auxiliary.FConditionFilterConN,1,nil,f,cc,fc,chkf,g,tg,ctc)
		end
	end
end
function Auxiliary.FConditionFilterConNChk(f,cc,fc,chkf,g)
	if g:IsExists(Auxiliary.TuneMagFusFilter,1,nil,g,chkf) then return false end
	local g1=g:Filter(Auxiliary.FConditionFilterConAndSub,nil,f,true)
	if chkf~=PLAYER_NONE then
		return g1:FilterCount(Auxiliary.FConditionCheckF,nil,chkf)~=0 and g1:GetCount()>=cc
	else return g1:GetCount()>=cc end
end
function Auxiliary.FConditionFunRep(f,cc,insf)
	return	function(e,g,gc,chkfnf)
				local c=e:GetHandler()
				if c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() then return false end
				if g==nil then return insf end
				local chkf=bit.band(chkfnf,0xff)
				local mg=g:Filter(Card.IsCanBeFusionMaterial,gc,e:GetHandler())
				mg=mg:Filter(Auxiliary.FConditionFilterConAndSub,nil,f,true)
				local mg1=mg:Filter(function(c) return not c:IsHasEffect(73941492) or not c.fuslimitfilter end,nil)
				if gc then
					if not gc:IsCanBeFusionMaterial(e:GetHandler()) or not Auxiliary.FConditionFilterConAndSub(gc,f,true) then return false end
					mg1:RemoveCard(gc)
					if (gc:IsLocation(LOCATION_MZONE) or chkf==PLAYER_NONE or mg1:IsExists(Auxiliary.FConditionCheckF,1,nil,chkf)) 
						and (not gc:IsHasEffect(73941492) or not gc.fuslimitfilter) and mg1:GetCount()>=cc-1 then return true end
					mg:AddCard(gc)
					local res=mg:IsExists(Auxiliary.FConditionFilterConNTune,1,nil,f,cc,e:GetHandler(),chkf,mg,nil,0,gc)
					mg:RemoveCard(gc)
					return res
				end
				if mg1:GetCount()>=cc and (chkf==PLAYER_NONE or mg1:FilterCount(Auxiliary.FConditionCheckF,nil,chkf)~=0) then return true end
				return mg:IsExists(Auxiliary.FConditionFilterConNTune,1,nil,f,cc,e:GetHandler(),chkf,mg,nil,0,nil)
			end
end
function Auxiliary.FOperationFunRep(f,cc,insf)
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=bit.band(chkfnf,0xff)
				local g=eg:Filter(Card.IsCanBeFusionMaterial,gc,e:GetHandler())
				g=g:Filter(Auxiliary.FConditionFilterConAndSub,nil,f,true)
				local mg1=g:Filter(function(c) return not c:IsHasEffect(73941492) or not c.fuslimitfilter end,nil)
				local p=tp
				local sfhchk=false
				--511004008 - Spiritual Fusion
				if Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp Duel.ConfirmCards(1-tp,g)
					if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				if gc then
					g:AddCard(gc)
					local matg=Group.CreateGroup()
					if g:IsExists(Auxiliary.FConditionFilterConNTune,1,nil,f,cc,e:GetHandler(),chkf,g,nil,0,gc) then
						g:RemoveCard(gc)
						local ct=1
						if cc>1 then
							matg:AddCard(gc)
							for i=1,cc-1 do
								Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
								local g1=g:FilterSelect(p,Auxiliary.FConditionFilterConN,1,1,nil,f,cc,e:GetHandler(),chkf,g,matg,ct)
								matg:Merge(g1)
								g:Sub(g1)
								ct=ct+1
							end
							matg:RemoveCard(gc)
						end
					else
						g:RemoveCard(gc)
						if chkf~=PLAYER_NONE and not gc:IsLocation(LOCATION_MZONE) then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
							local g1=mg1:FilterSelect(tp,Auxiliary.FConditionCheckF,1,1,nil,chkf)
							matg:Merge(g1)
							if cc>2 then
								Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
								local g2=mg1:Select(tp,cc-2,cc-2,g1:GetFirst())
								matg:Merge(g2)
							end
						else
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
							local g1=mg1:Select(tp,cc-1,cc-1,nil)
							matg:Merge(g1)
						end
					end
					if sfhchk then Duel.ShuffleHand(tp) end
					Duel.SetFusionMaterial(matg)
					return
				end
				local matg=Group.CreateGroup()
				if g:IsExists(Auxiliary.FConditionFilterConNTune,1,nil,f,cc,e:GetHandler(),chkf,g,nil,0) then
					local ct=0
					for i=1,cc do
						Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
						local g1=g:FilterSelect(p,Auxiliary.FConditionFilterConN,1,1,nil,f,cc,e:GetHandler(),chkf,g,matg,ct,nil)
						matg:Merge(g1)
						g:Sub(g1)
						ct=ct+1
					end
				else
					if chkf~=PLAYER_NONE then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
						local g1=mg1:FilterSelect(tp,Auxiliary.FConditionCheckF,1,1,nil,chkf)
						matg:Merge(g1)
						if cc>1 then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
							local g2=mg1:Select(tp,cc-1,cc-1,g1:GetFirst())
							matg:Merge(g2)
						end
					else
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
						local g1=mg1:Select(tp,cc,cc,nil)
						matg:Merge(g1)
					end
				end
				if sfhchk then Duel.ShuffleHand(tp) end
				Duel.SetFusionMaterial(matg)
			end
end
--Fusion monster, condition1 + condition2 * minc to maxc
function Auxiliary.AddFusionProcFunFunRep(c,f1,f2,minc,maxc,insf)
	local f1=function(c) return f1(c) and not c:IsHasEffect(6205579) end
	local f2=function(c) return f2(c) and not c:IsHasEffect(6205579) end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FConditionFunFunRep(f1,f2,minc,maxc,insf))
	e1:SetOperation(Auxiliary.FOperationFunFunRep(f1,f2,minc,maxc,insf))
	c:RegisterEffect(e1)
end
function Auxiliary.FConditionFilterFFRCol1(c,f1,f2,minc,chkf,mg,g2,ct,gc)
	local tg=Group.CreateGroup()
	local g=mg:Clone()
	tg:AddCard(c)
	g:RemoveCard(c)
	return g:IsExists(Auxiliary.FConditionFilterFFRCol2,1,c,f1,f2,minc,chkf,g,tg,ct,gc)
end
function Auxiliary.FConditionFilterFFRCol2(c,f1,f2,minc,chkf,mg,g2,ct,gc)
	local tg=g2:Clone()
	local g=mg:Clone()
	local ctc=ct+1
	if gc then
		tg:AddCard(gc)
		g:RemoveCard(gc)
	else
		tg:AddCard(c)
		g:RemoveCard(c)
	end
	if ctc==minc then
		return Auxiliary.FConditionFilterFFRColChk(f1,f2,minc,chkf,tg)
	else
		return g:IsExists(Auxiliary.FConditionFilterFFRCol2,1,nil,f1,f2,minc,chkf,g,tg,ctc,nil)
	end
end
function Auxiliary.FConditionFilterFFRColChk(f1,f2,minc,chkf,g)
	if g:IsExists(Auxiliary.TuneMagFusFilter,1,nil,g,chkf) then return false end
	return g:IsExists(Auxiliary.FConditionFilterFFR,1,nil,f1,f2,g,minc,chkf)
end
function Auxiliary.FConditionFilterFFR(c,f1,f2,mg,minc,chkf)
	if not f1(c) and not c:IsHasEffect(511002961) then return false end
	if chkf==PLAYER_NONE or aux.FConditionCheckF(c,chkf) then
		return minc<=0 or mg:IsExists(Auxiliary.FConditionFilterConAndSub,minc,c,f2,true)
	else
		local mg2=mg:Filter(Auxiliary.FConditionFilterConAndSub,c,f2,true)
		return mg2:GetCount()>=minc and mg2:IsExists(aux.FConditionCheckF,1,nil,chkf)
	end
end
function Auxiliary.FConditionFunFunRep(f1,f2,minc,maxc,insf)
	return	function(e,g,gc,chkfnf)
			local c=e:GetHandler()
			if c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() then return false end
			if g==nil then return insf end
			local chkf=bit.band(chkfnf,0xff)
			local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
			local mg1=mg:Filter(Auxiliary.FConditionFilterConAndSub,nil,f1,true)
			if gc then
				if not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
				return Auxiliary.FConditionFilterFFRCol1(gc,f1,f2,minc,chkf,mg,nil,0) 
					or mg1:IsExists(Auxiliary.FConditionFilterFFRCol1,1,nil,f1,f2,minc,chkf,mg,nil,0,gc)
			end
			return mg1:IsExists(Auxiliary.FConditionFilterFFRCol1,1,nil,f1,f2,minc,chkf,mg,nil,0)
		end
end
function Auxiliary.FConditionFilterExtraMaterial(c,mg,f)
	local g=mg:Clone()
	g:AddCard(c)
	if g:IsExists(Auxiliary.TuneMagFusFilter,1,nil,g,chkf) then return false end
	return Auxiliary.FConditionFilterConAndSub(c,f,true)
end
function Auxiliary.FOperationFunFunRep(f1,f2,minc,maxc,insf)
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
			local chkf=bit.band(chkfnf,0xff)
			local g=eg:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
			local mg1=g:Filter(Auxiliary.FConditionFilterConAndSub,nil,f1,true)
			local minct=minc
			local maxct=maxc
			local p=tp
			local sfhchk=false
			if Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
				p=1-tp Duel.ConfirmCards(1-tp,g)
				if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
			end
			if gc then
				local matg=Group.CreateGroup()
				local ct=0
				if Auxiliary.FConditionFilterFFRCol1(gc,f1,f2,minc,chkf,g,nil,0) then
					matg:AddCard(gc)
					for i=1,minct do
						Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
						local g1=g:FilterSelect(p,Auxiliary.FConditionFilterFFRCol2,1,1,nil,f1,f2,minct,chkf,g,matg,ct)
						matg:Merge(g1)
						g:Sub(g1)
						ct=ct+1
					end
					maxct=maxct-minct
					while g:IsExists(Auxiliary.FConditionFilterExtraMaterial,1,nil,g,f2) and maxct>0 and Duel.SelectYesNo(p,93) do
						Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
						local g1=g:FilterSelect(p,Auxiliary.FConditionFilterExtraMaterial,1,1,nil,g,f2)
						matg:Merge(g1)
						g:Sub(g1)
						maxct=maxct-1
					end
					matg:RemoveCard(gc)
					if sfhchk then Duel.ShuffleHand(tp) end
					Duel.SetFusionMaterial(matg)
				else
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					local matg=mg1:FilterSelect(p,Auxiliary.FConditionFilterFFRCol1,1,1,nil,f1,f2,minct,chkf,g,nil,ct,gc)
					matg:AddCard(gc)
					g:Sub(matg)
					ct=ct+1
					for i=1,minct-1 do
						Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
						local g1=g:FilterSelect(p,Auxiliary.FConditionFilterFFRCol2,1,1,nil,f1,f2,minct,chkf,g,matg,ct)
						matg:Merge(g1)
						g:Sub(g1)
						ct=ct+1
					end
					maxct=maxct-minct
					while g:IsExists(Auxiliary.FConditionFilterExtraMaterial,1,nil,g,f2) and maxct>0 and Duel.SelectYesNo(p,93) do
						Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
						local g1=g:FilterSelect(p,Auxiliary.FConditionFilterExtraMaterial,1,1,nil,g,f2)
						matg:Merge(g1)
						g:Sub(g1)
						maxct=maxct-1
					end
					matg:RemoveCard(gc)
					if sfhchk then Duel.ShuffleHand(tp) end
					Duel.SetFusionMaterial(matg)
				end
				return
			end
			local matg=Group.CreateGroup()
			local ct=0
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
			local matg=mg1:FilterSelect(p,Auxiliary.FConditionFilterFFRCol1,1,1,nil,f1,f2,minct,chkf,g,nil,ct,gc)
			g:Sub(matg)
			for i=1,minct do
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
				local g1=g:FilterSelect(p,Auxiliary.FConditionFilterFFRCol2,1,1,nil,f1,f2,minct,chkf,g,matg,ct)
				matg:Merge(g1)
				g:Sub(g1)
				ct=ct+1
			end
			maxct=maxct-minct
			while g:IsExists(Auxiliary.FConditionFilterExtraMaterial,1,nil,g,f2) and maxct>0 and Duel.SelectYesNo(p,93) do
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
				local g1=g:FilterSelect(p,Auxiliary.FConditionFilterExtraMaterial,1,1,nil,g,f2)
				matg:Merge(g1)
				g:Sub(g1)
				maxct=maxct-1
			end
			if sfhchk then Duel.ShuffleHand(tp) end
			Duel.SetFusionMaterial(matg)
		end
end
function Auxiliary.FilterBoolFunctionCFR(code,sub,fc)
	return	function(target)
				return target:IsFusionCode(code) or (sub and target:CheckFusionSubstitute(fc))
			end
end
--Fusion monster, name + condition * minc to maxc
function Auxiliary.AddFusionProcCodeFunRep(c,code1,f,minc,maxc,sub,insf)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	if c.material_count==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.material_count=1
		mt.material={code1}
	end
	local f=function(c) return f(c) and not c:IsHasEffect(6205579) end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FConditionFunFunRep(Auxiliary.FilterBoolFunctionCFR(code1,sub,c),f,minc,maxc,insf))
	e1:SetOperation(Auxiliary.FOperationFunFunRep(Auxiliary.FilterBoolFunctionCFR(code1,sub,c),f,minc,maxc,insf))
	c:RegisterEffect(e1)
end
--Ritual Summon, geq fixed lv
function Auxiliary.AddRitualProcGreater(c,filter)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(Auxiliary.RPGTarget(filter))
	e1:SetOperation(Auxiliary.RPGOperation(filter))
	c:RegisterEffect(e1)
end
function Auxiliary.RPGFilter(c,filter,e,tp,m,ft)
	if (filter and not filter(c)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	if ft>0 then
		return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetOriginalLevel(),c)
	else
		return mg:IsExists(Auxiliary.RPGFilterF,1,nil,tp,mg,c)
	end
end
function Auxiliary.RPGFilterF(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumGreater(Card.GetRitualLevel,rc:GetOriginalLevel(),rc)
	else return false end
end
function Auxiliary.RPGTarget(filter)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp)
					local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
					return ft>-1 and Duel.IsExistingMatchingCard(Auxiliary.RPGFilter,tp,LOCATION_HAND,0,1,nil,filter,e,tp,mg,ft)
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
			end
end
function Auxiliary.RPGOperation(filter)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local mg=Duel.GetRitualMaterial(tp)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=Duel.SelectMatchingCard(tp,Auxiliary.RPGFilter,tp,LOCATION_HAND,0,1,1,nil,filter,e,tp,mg,ft)
				local tc=tg:GetFirst()
				if tc then
					mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
					local mat=nil
					if ft>0 then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetOriginalLevel(),tc)
					else
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						mat=mg:FilterSelect(tp,Auxiliary.RPGFilterF,1,1,nil,tp,mg,tc)
						Duel.SetSelectedCard(mat)
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetOriginalLevel(),tc)
						mat:Merge(mat2)
					end
					tc:SetMaterial(mat)
					Duel.ReleaseRitualMaterial(mat)
					Duel.BreakEffect()
					Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
					tc:CompleteProcedure()
				end
			end
end
function Auxiliary.AddRitualProcGreaterCode(c,code1)
	if not c:IsStatus(STATUS_COPYING_EFFECT) and c.fit_monster==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.fit_monster={code1}
	end
	Auxiliary.AddRitualProcGreater(c,Auxiliary.FilterBoolFunction(Card.IsCode,code1))
end
--Ritual Summon, equal to fixed lv
function Auxiliary.AddRitualProcEqual(c,filter)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(Auxiliary.RPETarget(filter))
	e1:SetOperation(Auxiliary.RPEOperation(filter))
	c:RegisterEffect(e1)
end
function Auxiliary.RPEFilter(c,filter,e,tp,m,ft)
	if (filter and not filter(c)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	if ft>0 then
		return mg:CheckWithSumEqual(Card.GetRitualLevel,c:GetOriginalLevel(),1,99,c)
	else
		return mg:IsExists(Auxiliary.RPEFilterF,1,nil,tp,mg,c)
	end
end
function Auxiliary.RPEFilterF(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumEqual(Card.GetRitualLevel,rc:GetOriginalLevel(),0,99,rc)
	else return false end
end
function Auxiliary.RPETarget(filter)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp)
					local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
					return ft>-1 and Duel.IsExistingMatchingCard(Auxiliary.RPEFilter,tp,LOCATION_HAND,0,1,nil,filter,e,tp,mg,ft)
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
			end
end
function Auxiliary.RPEOperation(filter)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local mg=Duel.GetRitualMaterial(tp)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=Duel.SelectMatchingCard(tp,Auxiliary.RPEFilter,tp,LOCATION_HAND,0,1,1,nil,filter,e,tp,mg,ft)
				local tc=tg:GetFirst()
				if tc then
					mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
					local mat=nil
					if ft>0 then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetOriginalLevel(),1,99,tc)
					else
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						mat=mg:FilterSelect(tp,Auxiliary.RPEFilterF,1,1,nil,tp,mg,tc)
						Duel.SetSelectedCard(mat)
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						local mat2=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetOriginalLevel(),0,99,tc)
						mat:Merge(mat2)
					end
					tc:SetMaterial(mat)
					Duel.ReleaseRitualMaterial(mat)
					Duel.BreakEffect()
					Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
					tc:CompleteProcedure()
				end
			end
end
function Auxiliary.AddRitualProcEqualCode(c,code1)
	if not c:IsStatus(STATUS_COPYING_EFFECT) and c.fit_monster==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.fit_monster={code1}
	end
	Auxiliary.AddRitualProcEqual(c,Auxiliary.FilterBoolFunction(Card.IsCode,code1))
end
--Ritual Summon, equal to monster lv
function Auxiliary.AddRitualProcEqual2(c,filter)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(Auxiliary.RPETarget2(filter))
	e1:SetOperation(Auxiliary.RPEOperation2(filter))
	c:RegisterEffect(e1)
end
function Auxiliary.RPEFilter2(c,filter,e,tp,m,ft)
	if (filter and not filter(c)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	if ft>0 then
		return mg:CheckWithSumEqual(Card.GetRitualLevel,c:GetLevel(),1,99,c)
	else
		return mg:IsExists(Auxiliary.RPEFilter2F,1,nil,tp,mg,c)
	end
end
function Auxiliary.RPEFilter2F(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumEqual(Card.GetRitualLevel,rc:GetLevel(),0,99,rc)
	else return false end
end
function Auxiliary.RPETarget2(filter)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp)
					local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
					return ft>-1 and Duel.IsExistingMatchingCard(Auxiliary.RPEFilter2,tp,LOCATION_HAND,0,1,nil,filter,e,tp,mg,ft)
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
			end
end
function Auxiliary.RPEOperation2(filter)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local mg=Duel.GetRitualMaterial(tp)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=Duel.SelectMatchingCard(tp,Auxiliary.RPEFilter2,tp,LOCATION_HAND,0,1,1,nil,filter,e,tp,mg,ft)
				local tc=tg:GetFirst()
				if tc then
					mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
					local mat=nil
					if ft>0 then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),1,99,tc)
					else
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						mat=mg:FilterSelect(tp,Auxiliary.RPEFilter2F,1,1,nil,tp,mg,tc)
						Duel.SetSelectedCard(mat)
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
						local mat2=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),0,99,tc)
						mat:Merge(mat2)
					end
					tc:SetMaterial(mat)
					Duel.ReleaseRitualMaterial(mat)
					Duel.BreakEffect()
					Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
					tc:CompleteProcedure()
				end
			end
end
function Auxiliary.AddRitualProcEqual2Code(c,code1)
	if not c:IsStatus(STATUS_COPYING_EFFECT) and c.fit_monster==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.fit_monster={code1}
	end
	Auxiliary.AddRitualProcEqual2(c,Auxiliary.FilterBoolFunction(Card.IsCode,code1))
end
function Auxiliary.AddRitualProcEqual2Code2(c,code1,code2)
	if not c:IsStatus(STATUS_COPYING_EFFECT) and c.fit_monster==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.fit_monster={code1,code2}
	end
	Auxiliary.AddRitualProcEqual2(c,Auxiliary.FilterBoolFunction(Card.IsCode,code1,code2))
end
--add procedure to Pendulum monster, also allows registeration of activation effect
function Auxiliary.EnablePendulumAttribute(c,reg)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,10000000)
	e1:SetCondition(Auxiliary.PendCondition())
	e1:SetOperation(Auxiliary.PendOperation())
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	c:RegisterEffect(e1)
	--Can't be facedown in PZone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_TURN_SET)
	c:RegisterEffect(e2)
	--register by default
	if reg==nil or reg then
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(1160)
		e3:SetType(EFFECT_TYPE_ACTIVATE)
		e3:SetCode(EVENT_FREE_CHAIN)
		e3:SetRange(LOCATION_HAND)
		c:RegisterEffect(e3)
	end
end
function Auxiliary.PConditionFilter(c,e,tp,lscale,rscale)
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	return (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
		and lv>lscale and lv<rscale and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false)
		and not c:IsForbidden()
end
function Auxiliary.PendCondition()
	return	function(e,c,og)
				if c==nil then return true end
				local tp=c:GetControler()
				if c:GetSequence()~=6 then return false end
				local rpz=Duel.GetFieldCard(tp,LOCATION_SZONE,7)
				if rpz==nil then return false end
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				if lscale>rscale then lscale,rscale=rscale,lscale end
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				if ft<=0 then return false end
				if og then
					return og:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale)
				else
					return Duel.IsExistingMatchingCard(Auxiliary.PConditionFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp,lscale,rscale)
				end
			end
end
function Auxiliary.PendOperation()
	return	function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				local rpz=Duel.GetFieldCard(tp,LOCATION_SZONE,7)
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				if lscale>rscale then lscale,rscale=rscale,lscale end
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
				local tg=nil
				if og then
					tg=og:Filter(tp,Auxiliary.PConditionFilter,nil,e,tp,lscale,rscale)
				else
					tg=Duel.GetMatchingGroup(Auxiliary.PConditionFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,e,tp,lscale,rscale)
				end
				local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
				if ect and (ect<=0 or ect>ft) then ect=nil end
				if ect==nil or tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=tg:Select(tp,1,ft,nil)
					sg:Merge(g)
				else
					repeat
						local ct=math.min(ft,ect)
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
						local g=tg:Select(tp,1,ct,nil)
						tg:Sub(g)
						sg:Merge(g)
						ft=ft-g:GetCount()
						ect=ect-g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
					until ft==0 or ect==0 or not Duel.SelectYesNo(tp,210)
					local hg=tg:Filter(Card.IsLocation,nil,LOCATION_HAND)
					if ft>0 and ect==0 and hg:GetCount()>0 and Duel.SelectYesNo(tp,210) then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
						local g=hg:Select(tp,1,ft,nil)
						sg:Merge(g)
					end
				end
				Duel.HintSelection(Group.FromCards(c))
				Duel.HintSelection(Group.FromCards(rpz))
			end
end
function Auxiliary.IsMaterialListCode(c,code)
	if not c.material then return false end
	for i,mcode in ipairs(c.material) do
		if code==mcode then return true end
	end
	return false
end
function Auxiliary.IsMaterialListSetCard(c,setcode)
	return c.material_setcode and c.material_setcode==setcode
end
function Auxiliary.IsCodeListed(c,code)
	if not c.card_code_list then return false end
	for i,ccode in ipairs(c.card_code_list) do
		if code==ccode then return true end
	end
	return false
end	
--card effect disable filter(target)
function Auxiliary.disfilter1(c)
	return c:IsFaceup() and not c:IsDisabled() and (not c:IsType(TYPE_NORMAL) or bit.band(c:GetOriginalType(),TYPE_EFFECT)~=0)
end
--condition of EVENT_BATTLE_DESTROYING
function Auxiliary.bdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle()
end
--condition of EVENT_BATTLE_DESTROYING + opponent monster
function Auxiliary.bdocon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
--condition of EVENT_BATTLE_DESTROYING + to_grave
function Auxiliary.bdgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
--condition of EVENT_BATTLE_DESTROYING + opponent monster + to_grave
function Auxiliary.bdogcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
--condition of EVENT_TO_GRAVE + destroyed_by_opponent_from_field
function Auxiliary.dogcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousControler()==tp and c:IsReason(REASON_DESTROY) and rp~=tp
end
--condition of "except the turn this card was sent to the Graveyard"
function Auxiliary.exccon(e)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID() or e:GetHandler():IsReason(REASON_RETURN)
end
--flag effect for spell counter
function Auxiliary.chainreg(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(1)==0 then
		e:GetHandler():RegisterFlagEffect(1,RESET_EVENT+0x1fc0000+RESET_CHAIN,0,1)
	end
end
--default filter for EFFECT_CANNOT_BE_BATTLE_TARGET
function Auxiliary.imval1(e,c)
	return not c:IsImmuneToEffect(e)
end
--filter for EFFECT_CANNOT_BE_EFFECT_TARGET + opponent 
function Auxiliary.tgoval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
--filter for non-zero ATK 
function Auxiliary.nzatk(c)
	return c:IsFaceup() and c:GetAttack()>0
end
--filter for non-zero DEF
function Auxiliary.nzdef(c)
	return c:IsFaceup() and c:GetDefense()>0
end
--flag effect for summon/sp_summon turn
function Auxiliary.sumreg(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local code=e:GetLabel()
	while tc do
		if tc:GetOriginalCode()==code then 
			tc:RegisterFlagEffect(code,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1) 
		end
		tc=eg:GetNext()
	end
end
--sp_summon condition for fusion monster
function Auxiliary.fuslimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
--sp_summon condition for ritual monster
function Auxiliary.ritlimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end
--sp_summon condition for synchro monster
function Auxiliary.synlimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
--sp_summon condition for xyz monster
function Auxiliary.xyzlimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ
end
--sp_summon condition for pendulum monster
function Auxiliary.penlimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
--effects inflicting damage to tp
function Auxiliary.damcon1(e,tp,eg,ep,ev,re,r,rp)
	local e1=Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_DAMAGE)
	local e2=Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_RECOVER)
	local rd=e1 and not e2
	local rr=not e1 and e2
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex and (cp==tp or cp==PLAYER_ALL) and not rd and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_EFFECT_DAMAGE) then 
		return true 
	end
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	return ex and (cp==tp or cp==PLAYER_ALL) and rr and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_EFFECT_DAMAGE)
end
--filter for the immune effect of qli monsters
function Auxiliary.qlifilter(e,te)
	if te:IsActiveType(TYPE_MONSTER) and te:IsActivated() then
		local lv=e:GetHandler():GetLevel()
		local ec=te:GetHandler()
		if ec:IsType(TYPE_XYZ) then
			return ec:GetOriginalRank()<lv
		else
			return ec:GetOriginalLevel()<lv
		end
	else
		return false
	end
end
--filter for necro_valley test
function Auxiliary.nvfilter(c)
	return not c:IsHasEffect(EFFECT_NECRO_VALLEY)
end
function Auxiliary.NecroValleyFilter(f)
	return	function(target,...)
				return f(target,...) and not (target:IsHasEffect(EFFECT_NECRO_VALLEY) and Duel.IsChainDisablable(0))
			end
end

--Function to check the summon method used for the card. Credit goes to Cute-Nekomimi
function Card.IsSummonType(c,t)
	return bit.band(c:GetSummonType(),t)==t
end
--Cost for effect "You can banish this card from your Graveyard"
function Auxiliary.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

--add procedure to equip spells equipping by rule
function Auxiliary.AddEquipProcedure(c,p,f,eqlimit,cost,tg,op,con)
	--Note: p==0 is check equip spell controler, p==1 for opponent's, PLAYER_ALL for both player's monsters
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1068)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	if con then
		e1:SetCondition(con)
	end
	if cost~=nil then
		e1:SetCost(cost)
	end
	e1:SetTarget(Auxiliary.EquipTarget(tg,p,f))
	e1:SetOperation(op)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	if eqlimit~=nil then
		e2:SetValue(eqlimit)
	else
		e2:SetValue(Auxiliary.EquipLimit(f))
	end
	c:RegisterEffect(e2)
end
function Auxiliary.EquipLimit(f)
	return function(e,c)
				return not f or f(c,e,e:GetHandlerPlayer())
			end
end
function Auxiliary.EquipFilter(c,p,f,e,tp)
	return (p==PLAYER_ALL or c:IsControler(p)) and c:IsFaceup() and (not f or f(c,e,tp))
end
function Auxiliary.EquipTarget(tg,p,f)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local player=nil
				if p==0 then
					player=tp
				elseif p==1 then
					player=1-tp
				elseif p==PLAYER_ALL or p==nil then
					player=PLAYER_ALL
				end
				if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and Auxiliary.EquipFilter(chkc,player,f,e,tp) end
				if chk==0 then return player~=nil and Duel.IsExistingTarget(Auxiliary.EquipFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,player,f,e,tp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local g=Duel.SelectTarget(tp,Auxiliary.EquipFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,player,f,e,tp)
				if tg then tg(e,tp,eg,ep,ev,re,r,rp,g:GetFirst()) end
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_CHAIN_SOLVING)
				e1:SetReset(RESET_CHAIN)
				e1:SetLabel(Duel.GetCurrentChain())
				e1:SetLabelObject(e)
				e1:SetOperation(Auxiliary.EquipEquip)
				Duel.RegisterEffect(e1,tp)
				Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
			end
end
function Auxiliary.EquipEquip(e,tp,eg,ep,ev,re,r,rp)
	if re~=e:GetLabelObject() then return end
	local c=e:GetHandler()
	local tc=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TARGET_CARDS):GetFirst()
	if tc and c:IsRelateToEffect(re) and tc:IsRelateToEffect(re) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end

--add procedure to persistent traps
function Auxiliary.AddPersistentProcedure(c,p,f,category,property,hint1,hint2,con,cost,tg,op,anypos)
	--Note: p==0 is check persistent trap controler, p==1 for opponent's, PLAYER_ALL for both player's monsters
	--anypos is check for face-up/any
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1068)
	if category then
		e1:SetCategory(category)
	end
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	if hint1 or hint2 then
		if hint1==hint2 then
			e1:SetHintTiming(hint)
		elseif hint1 and not hint2 then
			e1:SetHintTiming(hint1,0)
		elseif hint2 and not hint1 then
			e1:SetHintTiming(0,hint2)
		else
			e1:SetHintTiming(hint1,hint2)
		end
	end
	if property then
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+property)
	else
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	end
	if con then
		e1:SetCondition(con)
	end
	if cost then
		e1:SetCost(cost)
	end
	e1:SetTarget(Auxiliary.PersistentTarget(tg,p,f))
	e1:SetOperation(op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(Auxiliary.PersistentTgCon)
	e2:SetOperation(Auxiliary.PersistentTgOp(anypos))
	c:RegisterEffect(e2)
end
function Auxiliary.PersistentFilter(c,p,f,e,tp)
	return (p==PLAYER_ALL or c:IsControler(p)) and (not f or f(c,e,tp))
end
function Auxiliary.PersistentTarget(tg,p,f)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local player=nil
				if p==0 then
					player=tp
				elseif p==1 then
					player=1-tp
				elseif p==PLAYER_ALL or p==nil then
					player=PLAYER_ALL
				end
				if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and Auxiliary.PersistentFilter(chkc,player,f,e,tp) end
				if chk==0 then return player~=nil and Duel.IsExistingTarget(Auxiliary.PersistentFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,player,f,e,tp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
				local g=Duel.SelectTarget(tp,Auxiliary.PersistentFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,player,f,e,tp)
				if tg then tg(e,tp,eg,ep,ev,re,r,rp,g:GetFirst()) end
			end
end
function Auxiliary.PersistentTgCon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
function Auxiliary.PersistentTgOp(anypos)
	return function(e,tp,eg,ep,ev,re,r,rp)
			local c=e:GetHandler()
			local tc=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):GetFirst()
			if c:IsRelateToEffect(re) and tc and (anypos or tc:IsFaceup()) and tc:IsRelateToEffect(re) then
				c:SetCardTarget(tc)
			end
		end
end
function Auxiliary.PersistentTargetFilter(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end
--Checks whether 2 cards are on the same column
--skip_ex is optional, indicates whether the Extra Monster Zone should be ignored (used in Blasting Fuse)
function Auxiliary.checksamecolumn(c1,c2,skip_ex)
	if not c1 or not c1:IsOnField() or not c2 or not c2:IsOnField() then return false end
	if c1==c2 then return false end
	local s1=c1:GetSequence()
	local s2=c2:GetSequence()
	if (c1:IsLocation(LOCATION_SZONE) and s1>=5)
		or (c2:IsLocation(LOCATION_SZONE) and s2>=5) then return false end
	if c1:GetControler()==c2:GetControler() then
		if skip_ex then
			return s2==s1
		else
			return s2==s1 or (s1==1 and s2==5) or (s1==3 and s2==6)
		end
	else
		if skip_ex then
			return s2==4-s1
		else
			return s2==4-s1 or (s1==1 and s2==6) or (s1==3 and s2==5)
		end
	end
end

pcall(dofile,"init.lua")
