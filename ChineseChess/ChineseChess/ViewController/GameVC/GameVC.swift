//
//  GameVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/16.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class GameVC: ChessVC {

	private lazy var chessBoardController: GameBoardController = GameBoardController(contentView: self.contentView, board: self.board, AI: self.AI, isUserInteractionEnabled: true)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.layoutTopAndBottom(target: self, attributes: [
			("设 置", #selector(settings)),
			("提 示", #selector(teachMe)),
			("返 回", #selector(back)),
			("新 局", #selector(newGame)),
			("悔 棋", #selector(regretOneStep)),
			("菜 单", #selector(showMenu)),
			])
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.refreshUI()
	}
	
	private func refreshUI() {
		self.AI.initBoard(withFile: UserPreference.shared.game.record)
		self.chessBoardController.reverse = UserPreference.shared.game.reverse
		self.chessBoardController.opposite = UserPreference.shared.game.opposite
		self.refreshTopBottom()
	}
	
	public override func updateUserPreference() {
		UserPreference.shared.game.record = self.AI.historyFile()
		UserPreference.shared.savePreference()
	}
	
}

// MARK: - GameSettings.
extension GameVC: GameSettingsViewDelegate {
	
	@objc private func newGame() {
		GameSettingsView().show(isNew: true, delegate: self)
	}
	
	@objc private func settings() {
		GameSettingsView().show(isNew: false, delegate: self)
	}
	
	func gameSettingsViewDidClickOk(isNew: Bool, levels: [UserPreference.Level]) {
		self.chessBoardController.gameSettingsViewDidClickOk(isNew: isNew, levels: levels)
		self.refreshTopBottom()
	}
	
	private func refreshTopBottom() {
		if UserPreference.shared.game.reverse {
			self.setSideState(top: ChessVC.SideState.side(level: UserPreference.shared.game.red, isRed: true), bottom: ChessVC.SideState.side(level: UserPreference.shared.game.black, isRed: false))
			self.setNickname(top: UserPreference.shared.game.red.description, bottom: UserPreference.shared.game.black.description)
		} else {
			self.setSideState(top: ChessVC.SideState.side(level: UserPreference.shared.game.black, isRed: false), bottom: ChessVC.SideState.side(level: UserPreference.shared.game.red, isRed: true))
			self.setNickname(top: UserPreference.shared.game.black.description, bottom: UserPreference.shared.game.red.description)
		}
	}
	
}

// MARK: - Menu.
extension GameVC: MenuViewDelegate, CharacterViewDelegate {

	@objc private func showMenu() {
		GameMenuView().show(delegate: self)
	}
	
	func menuView(_ menuView: NavigationView, didSelectRowAt index: Int) {
		switch index {
		case 0:
			self.chessBoardController.reverse = UserPreference.shared.game.reverse
			self.refreshTopBottom()
		case 1:
			self.chessBoardController.opposite = UserPreference.shared.game.opposite
		case 2:
			menuView.push(view: CharacterView(delegate: self, dataSource: self.AI.records.map({ return $0.item }), result: self.AI.state.result))
		case 3:
			break
		default:
			break
		}
	}
	
	func characterView(didClickAt index: Int) {
		if index == 0 {
			UserPreference.shared.history.saveHistory(name: self.name, description: self.detail, file: self.AI.historyFile())
			TextAlertView.show(in: self.contentView, text: "棋谱已保存")
		} else {
			UIPasteboard.general.string = "\(self.detail)\n\(self.AI.characters)"
			TextAlertView.show(in: self.contentView, text: "棋谱已复制到剪贴板")
		}
	}
	
	var detail: String {
		return "红方：\(UserPreference.shared.game.red.description)\n黑方：\(UserPreference.shared.game.black.description)\n回合数：\((self.AI.count + 1) >> 1)\n步数：\(self.AI.count)\n\(self.AI.state.result)"
	}
	
	private var name: String {
		return "\(Date.time) \(UserPreference.shared.game.red.description) \(self.AI.state.vs) \(UserPreference.shared.game.black.description)"
	}
	
}

// MARK: - Other
extension GameVC {
	
	@objc private func back() {
		WavHandler.playButtonWav()
		self.dismiss()
	}
	
	@objc private func regretOneStep() {
		self.chessBoardController.complexRegret()
	}
	
	@objc private func teachMe() {
		LoadingAlertView.show(message: "加载中...", isCloseButtonHidden: false, delegate: nil, completion: nil)
	}
	
}
