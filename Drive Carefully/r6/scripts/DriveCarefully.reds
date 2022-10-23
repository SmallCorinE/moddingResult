import DriveCarefully.Config.*

// During a traffic collision, charge a price based on the impact velocity

@wrapMethod(VehicleObject)
protected cb func OnTrafficBumpEvent(evt: ref<VehicleTrafficBumpEvent>) -> Bool {
    let impact: Float = evt.impactVelocityChange;
    let price: Int32 = (RoundMath(impact * 10.0) + 10) * 2 * costModifier();
    let playerPuppet = GetPlayer(this.GetGame());
    let transactionSystem = GameInstance.GetTransactionSystem(this.GetGame());

    let playerMoney: Int32 = transactionSystem.GetItemQuantity(playerPuppet, MarketSystem.Money());
    let charge: Int32 = Min(price, playerMoney);

    // Apply a cooldown of 1s, and only trigger when the player is driving
    if !GameObject.IsCooldownActive(this, n"bumpCooldown") && VehicleComponent.IsMountedToVehicle(playerPuppet.GetGame(), playerPuppet) {
        transactionSystem.RemoveItemByTDBID(playerPuppet, t"Items.money", charge);
        if enableMessages() {
            showPaymentMessage(this.GetGame(), charge, playerMoney == 0);
        };
    };
    return wrappedMethod(evt);
}

// Notification

final static func showPaymentMessage(gameInstance: GameInstance, price: Int32, insufficientFunds: Bool) -> Void {
    let onscreenMsg: SimpleScreenMessage;

    onscreenMsg.isShown = true;
    onscreenMsg.duration = 5.0;
    onscreenMsg.message = insufficientFunds ? "충돌이 감지되었습니다.\n파손을 보상할 자금이 부족합니다.\n조심해서 운전하십시오." : s"충돌이 감지되었습니다.\n부과 요금은 \(IntToString(price))€$ 입니다.";

    GameInstance.GetBlackboardSystem(gameInstance).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(onscreenMsg), true);
}
