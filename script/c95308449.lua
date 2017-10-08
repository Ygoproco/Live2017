--終焉のカウントダウン
function c95308449.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c95308449.cost)
	e1:SetOperation(c95308449.activate)
	c:RegisterEffect(e1)
	if not c95308449.global_check then
		c95308449.global_check=true
		c95308449[0]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TURN_END)
		ge1:SetCountLimit(1)
		ge1:SetOperation(c95308449.endop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetOperation(c95308449.winop)
		Duel.RegisterEffect(ge2,0)
	end
end
function c95308449.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function c95308449.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(95308449)~=0 then return end
	c:RegisterFlagEffect(95308449,RESET_PHASE+PHASE_END,0,20)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(95308449)
	e1:SetLabel(0)
	e1:SetOperation(c95308449.checkop)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END,20)
	Duel.RegisterEffect(e1,tp)
	c:RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END,0,20)
	c95308449[c]=e1
	table.insert(c95308449[0],e1)
end
function c95308449.endop(e,tp,eg,ep,ev,re,r,rp)
	for _,te in ipairs(c95308449[0]) do
		c95308449.checkop(te,te:GetOwnerPlayer(),nil,0,0,0,0,0)
	end
	c95308449.winop(e,tp,eg,ep,ev,re,r,rp)
end
function c95308449.checkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:GetHandler():SetTurnCounter(ct)
	e:SetLabel(ct)
	if ct==20 then
		e:GetHandler():ResetFlagEffect(1082946)
	end
end
function c95308449.winop(e,tp,eg,ep,ev,re,r,rp)
	local t={}
	t[0]=0
	t[1]=0
	for _,te in ipairs(c95308449[0]) do
		local p=te:GetOwnerPlayer()
		local ct=te:GetLabel()
		if ct==20 then
			t[p]=t[p]+1
		end
	end
	if t[0]>0 or t[1]>0 then
		if t[0]==t[1] then
			Duel.Win(PLAYER_NONE,0x11)
		elseif t[0]>t[1] then
			Duel.Win(0,0x11)
		else
			Duel.Win(1,0x11)
		end
	end
end
