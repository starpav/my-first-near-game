extends Control

# Note: replace with the name of your deployed smart contract
const CONTRACT_NAME = "coinmania.aiko.testnet"

onready var login_button = $ColorRect/SignInButton
onready var player_name_label = $ColorRect/PlayerNameLabel

var config = {
	"network_id": "testnet",
	"node_url": "https://rpc.testnet.near.org",
	"wallet_url": "https://wallet.testnet.near.org",
}
var wallet_connection
var balance_value = 0

func _ready():
	player_name_label.hide()
	$ColorRect/ErrorLabel.hide()
	$ColorRect/BuyButton.hide()
	$ColorRect/CenterContainer/VBoxContainer/StartButton.hide()
	$ColorRect/BalanceLabel.hide()
	$ColorRect/RefreshButton.hide()
	$ColorRect/RulesLabel.hide()
	if Near.near_connection == null:
		Near.start_connection(config)
	
	wallet_connection = WalletConnection.new(Near.near_connection)
	wallet_connection.connect("user_signed_in", self, "_on_user_signed_in")
	wallet_connection.connect("user_signed_out", self, "_on_user_signed_out")
	if wallet_connection.is_signed_in():
		_on_user_signed_in(wallet_connection)

func _on_user_signed_in(wallet: WalletConnection):
	login_button.set_text("Sign Out")
	player_name_label.show()
	player_name_label.set_text(wallet.get_account_id())
	$ColorRect/CenterContainer/VBoxContainer/StartButton.show()
	$ColorRect/BuyButton.show()
	$ColorRect/BalanceLabel.show()
	$ColorRect/RefreshButton.show()
	$ColorRect/RulesLabel.show()
	
func _on_user_signed_out(wallet: WalletConnection):
	login_button.set_text("Sign In")
	player_name_label.hide()
	$ColorRect/CenterContainer/VBoxContainer/StartButton.hide()
	$ColorRect/BuyButton.hide()
	$ColorRect/BalanceLabel.hide()
	$ColorRect/RefreshButton.hide()
	$ColorRect/RulesLabel.hide()

func _on_StartButton_pressed():
	if wallet_connection.is_signed_in() and balance_value >= 10:
		var args = {"receiver_id": CONTRACT_NAME, \
		"amount": "1000000000"}
		wallet_connection.call_change_method(CONTRACT_NAME, "send", args, \
		Near.DEFAULT_FUNCTION_CALL_GAS) 
		get_tree().change_scene("res://src/Main/Game.tscn")
	else:
		$ColorRect/ErrorLabel.show()

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_SignInButton_pressed():
	if wallet_connection.is_signed_in():
		wallet_connection.sign_out()
	else:
		wallet_connection.sign_in(CONTRACT_NAME)

func _on_RefreshButton_pressed():
	if wallet_connection.is_signed_in():
		var args = {"account_id": wallet_connection.get_account_id()}
		var result = Near.call_view_method(CONTRACT_NAME, "ft_balance_of", args)
		if result is GDScriptFunctionState:
			result = yield(result, "completed")
		if result.has("error"):
			pass
		else:
			var data = result.data
			balance_value = int(data) / 100000000
			$ColorRect/BalanceLabel.set_text(str(balance_value))
			$ColorRect/ErrorLabel.hide()

func _on_BuyButton_pressed():
	if wallet_connection.is_signed_in():
		$ColorRect/ErrorLabel.hide()
		var args = {"account_id": wallet_connection.get_account_id()}
		wallet_connection.call_change_method(CONTRACT_NAME, "buy", args, \
		Near.DEFAULT_FUNCTION_CALL_GAS, 1)
