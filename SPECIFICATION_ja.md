# Ginghamライブラリ 詳細仕様書

## 1. 概要

Ginghamは、グリッドベースの戦術シミュレーションゲーム（SRPGなど）のための3次元移動システムライブラリです。以下の主要機能を提供します：

- 3次元グリッド空間での経路探索（A*アルゴリズム）
- 複数キャラクターの同時移動シミュレーション
- チーム単位での衝突判定と処理
- 高低差を考慮した移動制御
- スキル・攻撃範囲の計算

## 2. クラス構成

### 2.1 Position（座標クラス）

3次元空間上の座標を表現するクラスです。

**属性**
- `x` (Integer): X座標
- `y` (Integer): Y座標  
- `z` (Integer): Z座標（高さ）

**メソッド**
- `initialize(x, y, z)`: 座標を初期化
- `to_s`: "(x,y,z)"形式の文字列を返す
- `inspect`: to_sと同じ

### 2.2 Direction（方向定数モジュール）

テンキー表記による8方向の定数を定義するモジュールです。

**定数**
- `D2 = 2`: 下方向（↓）
- `D4 = 4`: 左方向（←）
- `D6 = 6`: 右方向（→）
- `D8 = 8`: 上方向（↑）

### 2.3 Cell（グリッドセルクラス）

3次元空間の1マスを表現するクラスです。

**属性**
- `x, y, z` (Integer): 座標
- `is_occupied` (Boolean): 占有フラグ（誰かがいるか）
- `is_passable` (Boolean): 通行可能フラグ
- `is_ground` (Boolean): 地面フラグ（空中でない）
- `is_move_path` (Boolean): 移動経路フラグ
- `is_locked` (Boolean): ロックフラグ（状態変更禁止）

**メソッド**
- `occupied?`: 占有されているか
- `passable?`: 通行可能か
- `ground?`: 地面か
- `sky?`: 空中か（地面でない）
- `move_path?`: 移動経路か
- `locked?`: ロックされているか
- `set_ground`: 地面として設定（is_ground=true, is_passable=true）
- `clear_path`: 経路情報をクリア（ロックされていない場合のみ）
- `lock`: ロック状態にする
- `unlock`: ロック解除
- `==`: 座標による等価判定

### 2.4 Space（3次元空間クラス）

グリッドベースの3次元空間を管理するクラスです。

**属性**
- `width` (Integer): 幅（X方向のサイズ）
- `depth` (Integer): 奥行き（Y方向のサイズ）
- `height` (Integer): 高さ（Z方向のサイズ）
- `cells` (Array): 3次元配列[x][y][z]によるセル管理

**主要メソッド**
- `initialize(width, depth, height)`: 指定サイズの空間を生成
- `height_at(x, y)`: 指定座標の地面の高さを取得（地面がない場合は0）
- `ground_at(x, y)`: 指定座標の地表セルを取得
- `rotate_right(center, target)`: centerを中心にtargetを右90度回転
- `rotate_left(center, target)`: centerを中心にtargetを左90度回転
- `rotate_reverse(center, target)`: centerを中心にtargetを180度回転
- `build_range_cell(waypoint, query)`: 方向を考慮した範囲セルを構築
  - `query`: `{move: 移動力, height: 高さ制限}`の形式
- `build_all_range_cells(waypoint, query_list)`: 複数の範囲セルを構築し合成
- `reset_move_path_info(force=false)`: 移動経路情報をリセット

### 2.5 Waypoint（経路ポイントクラス）

移動経路上の1点（位置＋向き）を表現するクラスです。

**属性**
- `cell` (Cell): 位置
- `direction` (Integer): 向き（Direction定数）
- `parent` (Waypoint): 親Waypoint（経路の前の点）
- `cost` (Integer): このステップのコスト
- `sum_cost` (Integer): 累積コスト
- `chains` (Array<Waypoint>): 経路全体
- `is_locked` (Boolean): ロック状態

**クラスメソッド**
- `detect_direction(from, target_cell)`: 2点間の方向を検出
  - 8方向のうち最も近い方向を返す

**インスタンスメソッド**
- `calc_cost`: 移動コストを計算
  - 直進移動: 10
  - 90度回転: 5
  - 180度回転: 10
- `pick_parents`: 親を含む経路全体を配列で取得
- `update`: コストと経路を再計算
- `turning?`: 回転動作かどうか
- `moving?`: 移動動作かどうか
- `lock`: ロック
- `unlock`: ロック解除

### 2.6 Actor（キャラクタークラス）

移動可能なキャラクターを表現するクラスです。

**属性**
- `waypoint` (Waypoint): 現在位置と向き
- `weight` (Integer): 重量（衝突時の優先度）
- `team_id` (Integer): チームID
- `move_status` (Integer): 移動状態（MoveStatus定数）
- `move_power` (Integer): 移動力
- `jump_power` (Integer): ジャンプ力
- `move_steps` (Array<Waypoint>): 移動経路

**メソッド**
- `initialize(waypoint:, weight:, team_id:, move_power:, jump_power:)`
- `move_end?`: 移動完了判定（move_stepsが空）
- `clear_move_steps(force=false)`: 移動経路をクリア
- `dump_move_steps`: 移動経路を文字列化（デバッグ用）

### 2.7 PathFinder（経路探索クラス）

A*アルゴリズムベースの経路探索を行うクラスです。

**クラスメソッド**

#### `find_move_path(space, from, to, move_power, jump_power, margin=0)`
移動経路を探索します。

**パラメータ**
- `space` (Space): 探索空間
- `from` (Waypoint): 開始地点
- `to` (Cell): 目標地点
- `move_power` (Integer): 移動力
- `jump_power` (Integer): ジャンプ力
- `margin` (Integer): 方向転換のための余力

**戻り値**
- 最短コストの経路（Waypoint）、到達不可能な場合はnil

**アルゴリズム**
- A*アルゴリズムを使用
- ヒューリスティック関数：マンハッタン距離
- 高低差がjump_powerを超える場合は移動不可
- 累積コストがmove_power - marginを超える場合は移動不可

#### `find_skill_path(space, from, to, max_height)`
スキル用の直線的な経路を探索します。

**パラメータ**
- `space` (Space): 探索空間
- `from` (Waypoint): 開始地点
- `to` (Cell): 目標地点
- `max_height` (Integer): 最大高さ差

**特徴**
- 障害物や高さ制限を考慮した直線経路
- 移動コストは考慮しない

#### `find_adjacent_waypoints(space, wp, jump_power)`
隣接する移動可能なWaypointを取得します。

**戻り値**
- 4方向の移動可能なWaypointの配列

#### `find_adjacent_cells(space, cell, jump_power)`
隣接する移動可能なCellを取得します。

### 2.8 MoveStatus（移動状態定数）

移動状態を表す定数を定義するモジュールです。

**定数**
- `DEFAULT = 0`: 通常状態
- `STAY = 1`: 待機中（同チームとの衝突により待機）
- `STOPPED = 2`: 停止（敵との衝突により停止）
- `FINISHED = 3`: 移動完了

### 2.9 MoveFrame（移動フレームクラス）

ある時点での全Actorの状態スナップショットを保持するクラスです。

**属性**
- `index` (Integer): フレーム番号
- `actors` (Array<Actor>): Actorの配列（ディープコピー）

**メソッド**
- `initialize(index, actors)`: フレームを生成（actorsはディープコピー）

### 2.10 TimeLine（タイムラインクラス）

移動とアクションの記録を管理するクラスです。

**属性**
- `move_records` (Array): 移動記録
- `action_records` (Array): アクション記録

### 2.11 MoveSimulator（移動シミュレータ）

複数Actorの同時移動をシミュレートするクラスです。

**クラスメソッド**

#### `next_step(current_step_index, actors)`
1ステップ進めます。

**衝突判定ロジック**
1. 各Actorの次の移動先を取得
2. 移動先でのグループ分け
3. 衝突処理：
   - **目標地点が占有されている場合**：
     - 同チームのみ: 全員待機（STAY）
     - 敵チーム含む: 全員停止（STOPPED）
   - **目標地点が空いている場合**：
     - 最も重いActorが移動
     - 同チームの他Actor: 待機（STAY）
     - 敵チームのActor: 停止（STOPPED）

#### `record(actors)`
全Actorの移動を完了までシミュレートします。

**戻り値**
- MoveFrameの配列（各ステップのスナップショット）

### 2.12 Naterua（ゲームマスタークラス）

ゲーム進行を管理するクラスです。

**属性**
- `turn` (Integer): ターン数
- `step_index` (Integer): ステップインデックス

## 3. 使用例

### 3.1 基本的な経路探索

```ruby
# 空間の作成
space = Gingham::Space.new(10, 10, 5)

# 地面の設定
space.cells[5][5][0].set_ground

# 開始地点と目標地点
from = Gingham::Waypoint.new(
  cell: space.cells[0][0][0],
  direction: Gingham::Direction::D6
)
to = space.cells[5][5][0]

# 経路探索
path = Gingham::PathFinder.find_move_path(
  space, from, to, 
  move_power: 10, 
  jump_power: 2
)
```

### 3.2 複数キャラクターの移動シミュレーション

```ruby
# Actorの作成
actor1 = Gingham::Actor.new(
  waypoint: waypoint1,
  weight: 50,
  team_id: 1,
  move_power: 5,
  jump_power: 2
)

actor2 = Gingham::Actor.new(
  waypoint: waypoint2,
  weight: 60,
  team_id: 2,
  move_power: 4,
  jump_power: 1
)

# 移動経路の設定
actor1.move_steps = [step1, step2, step3]
actor2.move_steps = [step4, step5]

# シミュレーション実行
frames = Gingham::MoveSimulator.record([actor1, actor2])
```

## 4. 注意事項

- 座標系は0ベースインデックス
- 高さ（Z座標）は下から上に向かって増加
- 移動コストは整数値で計算（小数点以下切り捨て）
- 同一チームのActorは通り抜け可能、異なるチームは衝突
- ロックされたCellやWaypointは状態変更不可