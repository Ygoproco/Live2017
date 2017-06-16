--デモンズ・チェーン
function c50078509.initial_effect(c)
	aux.AddPersistentProcedure(c,nil,c50078509.filter,CATEGORY_DISABLE,nil,nil,0x1c0,nil,nil,c50078509.target)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e3)
	--cannot attack
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e4)
	--Destroy
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(c50078509.descon)
	e5:SetOperation(c50078509.desop)
	c:RegisterEffect(e5)
end
function c50078509.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function c50078509.target(e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
end
function c50078509.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
function c50078509.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
