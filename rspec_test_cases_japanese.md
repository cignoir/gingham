# Gingham RSpecテストケース一覧（日本語）

このファイルは、Ginghamプロジェクトの全RSpecテストケースとその期待値を日本語で整理したものです。

## 1. Actor (spec/gingham/actor_spec.rb)
- **クラス定義**: Gingham::Actorクラスが正しく定義されていること

## 2. Direction (spec/gingham/direction_spec.rb)
- **モジュール定義**: Gingham::Directionモジュールが正しく定義されていること

## 3. Cell (spec/gingham/cell_spec.rb)
- **クラス定義**: Gingham::Cellクラスが正しく定義されていること
- **占有状態**: occupied?がtrue時、passable?はfalseを返す
- **非占有状態**: occupied?がfalse時、passable?もfalseを返す
- **通行可能**: passable?がtrueを返す場合の動作確認
- **通行不可**: passable?がfalseを返す場合の動作確認
- **地面判定**: ground?がtrue時、sky?はfalseを返す
- **空中判定**: ground?がfalse時、sky?はtrueを返す

## 4. MoveStatus (spec/gingham/move_status_spec.rb)
- **モジュール定義**: Gingham::MoveStatusモジュールが正しく定義されていること

## 5. MoveFrame (spec/gingham/move_frame_spec.rb)
- **クラス定義**: Gingham::MoveFrameクラスが正しく定義されていること

## 6. MoveSimulator (spec/gingham/move_simulator_spec.rb)
- **クラス定義**: Gingham::MoveSimulatorクラスが正しく定義されていること

### next_stepメソッド
- **干渉なし移動**: 全アクターが目的地に到達し、move_statusがDEFAULTになる
- **同チーム同一セル進入**: 最も重いアクター以外はSTAY状態で元の位置に留まる
- **敵チーム同一セル進入**: 全アクターがSTOPPED状態になり、move_stepsが減少
- **同チーム空きセル**: 最も重いアクターのみ目的地到達、他はSTAY状態
- **敵チーム空きセル**: 最も重いアクターが目的地到達、全員STOPPED状態

### simulateメソッド
- **衝突なしシミュレーション**: 全アクターが目的地に到達
- **同チーム衝突**: すり抜けて両方が目的地に到達
- **向かい合い衝突**: 重い方が進み、軽い方は元の位置でSTAY
- **異チーム衝突**: 重い方が進み、軽い方は元の位置に留まる
- **特殊ケース**: 同一位置から異なる方向への移動で正しく方向を向く

## 7. Space (spec/gingham/space_spec.rb)
- **クラス定義**: Gingham::Spaceクラスが正しく定義されていること
- **初期化**: 指定サイズで3次元配列が生成される
- **高さ取得**: height_atが指定座標の地面の最大高さを返す
- **地面セル取得**: ground_atが最も高い地面セルを返す
- **右90度回転**: rotate_rightで(2,4)→(4,2)への座標変換
- **左90度回転**: rotate_leftで(2,4)→(0,2)への座標変換
- **180度回転**: rotate_reverseで(2,4)→(2,0)への座標変換
- **範囲セル構築**: build_range_cellがテンキー方向の数値クエリから対応セルを生成
- **複数範囲セル構築**: build_all_range_cellsが複数クエリから対応セルリストを生成

## 8. TimeLine (spec/gingham/time_line_spec.rb)
- **クラス定義**: Gingham::TimeLineクラスが正しく定義されていること

## 9. Position (spec/gingham/position_spec.rb)
- **クラス定義**: Gingham::Positionクラスが正しく定義されていること
- **初期化**: x=1, y=2, z=3が正しく設定される

## 10. PathFinder (spec/gingham/path_finder_spec.rb)
- **クラス定義**: Gingham::PathFinderクラスが正しく定義されていること
- **隣接ウェイポイント検索**: find_adjacent_waypointsが上下左右4方向の隣接ウェイポイントを返す
- **隣接セル検索**: find_adjacent_cellsが上下左右4方向の隣接セルを返す

### find_move_pathメソッド
- **基本経路探索**: A*アルゴリズムによる最短経路とコスト計算
- **移動力制限**: 移動力不足時は目的地に到達不可
- **ジャンプ力制限**: 高さ4差はジャンプ力4以上が必要

### find_skill_pathメソッド
- **スキル経路**: 方向転換を含む詳細な経路とコスト計算

## 11. Naterua (spec/gingham/naterua_spec.rb)
- **クラス定義**: Gingham::Nateruaクラスが正しく定義されていること

## 12. Gingham本体 (spec/gingham_spec.rb)
- **バージョン番号**: VERSIONがnilでないこと

## 13. Waypoint (spec/gingham/waypoint_spec.rb)
- **クラス定義**: Gingham::Waypointクラスが正しく定義されていること
- **方向検出**: detect_directionが相対位置から正しい方向(2,4,6,8)を返す

### calc_costメソッド
- **同一セル方向転換**: コスト5または10
- **異なるセル移動**: コスト10
- **方向転換込み移動**: コスト15-20

### その他のメソッド
- **初期化**: セル、方向、親、コスト、累積コストの設定
- **親連鎖取得**: pick_parentsがルートから現在までの経路を構築
- **情報更新**: updateでコストと連鎖の再計算
- **方向転換判定**: turning?が同一セルで親ありならtrue
- **移動判定**: moving?が異なるセルへの移動ならtrue
- **等価性**: ==でセルと方向が同じならtrue（親は無視）
- **文字列表現**: to_sとinspectが"(親座標)/親方向->(座標)/方向:コスト/累積コスト"形式で出力

## テスト実行方法

```bash
# 全テスト実行
rake spec

# 特定ファイルのテスト実行
bundle exec rspec spec/gingham/path_finder_spec.rb

# 特定のテストケースのみ実行
bundle exec rspec spec/gingham/path_finder_spec.rb -e "finds path"
```