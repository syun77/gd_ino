//------------------------------------------------------------------------------
// 			アクションゲームテスト
// 			OMEGA（　゜ワ゜）ノ　2007/01/03
//					code copyed&edited from RECT WINDER
//							thanks to kenmo
//------------------------------------------------------------------------------

import hell;
import std.random;
import std.string;
import std.math;
import std.math2;
import std.stream;

// 画面サイズ
const int g_width = 320;
const int g_height = 240;
// キャラクタサイズ
static const int CHAR_SIZE = 16;

// ２次元ベクトル
class Vec2D
{
public:
	/**
	 * 値
	 */
	float x, y;
	/**
	 * コンストラクタ
	 */
	this(float x=0, float y=0) { this.x = x; this.y = y; }
	this(Vec2D v)		   { this.x = v.x ; this.y = v.y; }
	void opAddAssign(Vec2D v)  { x += v.x; y += v.y; }
	void opSubAssign(Vec2D v)  { x -= v.x; y -= v.y; }
	void opMulAssign(float a)  { x *= a;   y *= a;   }
	void opDivAssign(float a)  { x /= a;   y /= a;   }
	/**
	 * 正規化
	 */
	void normalize()
	{
		float len = length();
		if(len == 0) return;
		x /= len; y /= len;
	}
	/**
	 * 距離
	 */
	float length()   { return sqrt(lengthSq());}
	/**
	 * 距離の２乗
	 */
	float lengthSq() { return x*x + y*y; }
}


// フィールド
class Field
{
public:
	int field[];
	int timer;
	
	GameMain gamemain;
	PlayerData playerdata;
	
	static const int FIELD_X_MAX = 128;
	static const int FIELD_Y_MAX = 128;
	
	static const int GRAPHIC_OFFSET_X = -16 - 16*2;
	static const int GRAPHIC_OFFSET_Y = 8 - 16*2;
	
	static const float SCROLLPANEL_SPEED = 2.0;
	
	enum{
		FIELD_NONE,		// なし
		FIELD_HIDEPATH,		// 隠しルート(見えるけど判定のないブロック)
		FIELD_UNVISIBLE,	// 不可視ブロック(見えないけど判定があるブロック)
		FIELD_BLOCK,		// 通常ブロック
		FIELD_BAR,		// 床。降りたり上ったりできる
		FIELD_SCROLL_L,		// ベルト床左
		FIELD_SCROLL_R,		// ベルト床右
		FIELD_SPIKE,		// トゲ
		FIELD_SLIP,		// すべる
		FIELD_ITEM_BORDER,	// アイテムチェック用
		FIELD_ITEM_POWERUP,	// パワーアップ
		FIELD_ITEM_FUJI,	// ふじ系
		FIELD_ITEM_BUSHI,
		FIELD_ITEM_APPLE,
		FIELD_ITEM_V,
		FIELD_ITEM_TAKA,	// たか系
		FIELD_ITEM_SHUOLDER,
		FIELD_ITEM_DAGGER,
		FIELD_ITEM_KATAKATA,
		FIELD_ITEM_NASU,	// なす系
		FIELD_ITEM_BONUS,
		FIELD_ITEM_NURSE,
		FIELD_ITEM_NAZUNA,
		FIELD_ITEM_GAMEHELL,	// くそげー系
		FIELD_ITEM_GUNDAM,
		FIELD_ITEM_POED,
		FIELD_ITEM_MILESTONE,
		FIELD_ITEM_1YEN,
		FIELD_ITEM_TRIANGLE,
		FIELD_ITEM_OMEGA,	// 隠し
		FIELD_ITEM_LIFE,	// ハート
		FIELD_ITEM_STARTPOINT,	// 開始地点
		FIELD_ITEM_MAX,
	}
public:
	this(GameMain gm)
	{
		gamemain = gm;
		playerdata = gm.playerdata;
		timer = 0;
		loadFieldData("resource/dat/field.dat");
	}
	void loadFieldData(char[] fileName){
		field = new int[FIELD_Y_MAX * FIELD_X_MAX];
		
		char buf[][] = split(cast(char[])std.file.read(fileName) , "\n");
		char decoder[] = " HUB~<>*I PabcdefghijklmnopqrzL@";
		for(int yy=0;yy<buf[].length;yy++){
			char buf2[] = buf[yy];
			for(int xx=0;xx<buf2.length -1;xx++){
				field[yy * FIELD_X_MAX + xx] = find(decoder , buf2[xx]);
			}
		}
	}
	
	void move()
	{
		timer++;
	}
	
	Vec2D getStartPoint(){
		Vec2D v = new Vec2D(CHAR_SIZE * 2,CHAR_SIZE * 2);
		for(int yy = 0 ;yy < FIELD_Y_MAX;yy++){
			for(int xx = 0;xx < FIELD_X_MAX;xx++){
				if(getField(xx,yy) == FIELD_ITEM_STARTPOINT){
					v.x = cast(float)(xx * CHAR_SIZE);
					v.y = cast(float)(yy * CHAR_SIZE);
					eraseField(xx,yy);
				}
			}
		}
		return v;
	}
	
	bool isWall(int x,int y){
		if(field[y * FIELD_X_MAX + x] != FIELD_NONE && 
			field[y * FIELD_X_MAX + x] != FIELD_HIDEPATH && 
			field[y * FIELD_X_MAX + x] != FIELD_BAR && 
			!isItem(x,y)) return true;
		return false;
	}
	bool isRidable(int x,int y){
		if(field[y * FIELD_X_MAX + x] != FIELD_NONE &&
			field[y * FIELD_X_MAX + x] != FIELD_HIDEPATH &&
			!isItem(x,y)) return true;
		return false;
	}
	bool isSpike(int x,int y){
		if(field[y * FIELD_X_MAX + x] == FIELD_SPIKE) return true;
		return false;
	}
	
	int getField(int x,int y){return field[y * FIELD_X_MAX + x];}
	
	bool isItem(int x,int y){
		if(field[y * FIELD_X_MAX + x] < FIELD_ITEM_BORDER || field[y * FIELD_X_MAX + x] == FIELD_ITEM_STARTPOINT) return false;
		return true;
	}
	
	bool isItemGetable(int x,int y){
		if(!isItem(x,y)) return false;
		if(field[y * FIELD_X_MAX + x] == FIELD_ITEM_OMEGA && isHiddenSecret()) return false;
		return true;
	}
	bool isHiddenSecret(){
		if(playerdata.getItemCount() < 15) return true;
		return false;
	}
	
	void eraseField(int x,int y){
		field[y * FIELD_X_MAX + x] = FIELD_NONE;
	}
	
	void draw()
	{
		Vec2D v = gamemain.view.getPosition();
		int ofs_x = CHAR_SIZE - (cast(int)v.x) % CHAR_SIZE;
		int ofs_y = CHAR_SIZE - (cast(int)v.y) % CHAR_SIZE;
		for(int xx = -12;xx < 13;xx++){
			for(int yy = -8;yy < 9;yy++){
				int fx = xx + cast(int)(v.x / CHAR_SIZE);
				int fy = yy + cast(int)(v.y / CHAR_SIZE);
				if(fx < 0 || fy < 0 || fx >= FIELD_X_MAX || fy >= FIELD_Y_MAX) continue;
				
				int gy = (timer / 10) % 4;
				int gx = field[fy * FIELD_X_MAX + fx];
				
				if(isItem(fx,fy)){
					gx = gx - (FIELD_ITEM_BORDER + 1);
					gy = 4 + (gx / 16);
					gx = gx % 16;
				}
				
				if(isHiddenSecret() && field[fy * FIELD_X_MAX + fx] == FIELD_ITEM_OMEGA) continue;
				
				Hell_draw("ino" ,
					(xx + 12)* CHAR_SIZE + ofs_x + GRAPHIC_OFFSET_X,
					(yy + 8) * CHAR_SIZE + ofs_y + GRAPHIC_OFFSET_Y ,
					gx * 16 , gy * 16 , 16,16);
				/*	// デバッグ用
				Hell_drawFont(std.string.toString(field[fy * FIELD_X_MAX + fx]),
					(xx + 12)* CHAR_SIZE + ofs_x + GRAPHIC_OFFSET_X,
					(yy + 8) * CHAR_SIZE + ofs_y + GRAPHIC_OFFSET_Y);
				*/
			}
		}
	}
}

// プレーヤー
class Player
{
public:
	int life;		// ライフポイント
	int jump_cnt;		// ジャンプ回数
	
	int timer;		// タイマ
	
	Vec2D position;		// 座標
	Vec2D speed;		// 速度
	int direction;		// 方位
	
	Vec2D jumped_point;	// ジャンプ座標
	
	Field field;		// フィールド
	int state;		// 状態
	int item_get;		// 取得アイテム
	
	int wait_timer;
	
	GameMain gamemain;	// ゲームメインのアクセス用
	PlayerData playerdata;
	
	static const float PLAYER_SPEED = 2.0;
	static const float PLAYER_GRD_ACCRATIO = 0.04;
	static const float PLAYER_AIR_ACCRATIO = 0.01;
	static const float PLAYER_JUMP = -4.0;
	static const float PLAYER_GRAVITY = 0.2;
	static const float PLAYER_FALL_SPEEDMAX = 4.0;
	static const float VIEW_DIRECTION_OFFSET = 30.0;
	static const int WAIT_TIMER_INTERVAL = 10;
	static const int LIFE_RATIO = 400;
	static const int MUTEKI_INTERVAL = 50;
	static const int START_WAIT_INTERVAL = 50;
	
	static const float LUNKER_JUMP_DAMAGE1 = 40.0;
	static const float LUNKER_JUMP_DAMAGE2 = 96.0;
	
	enum{
		STATE_START,
		STATE_NORMAL,
		STATE_ITEMGET,
		STATE_MUTEKI,
		STATE_DEAD,
	}
public:
	this(GameMain gm){
		gamemain = gm;
		timer = 0;
		wait_timer = 0;
		
		jump_cnt = 0;
		position = new Vec2D(cast(float)CHAR_SIZE * 2, cast(float)CHAR_SIZE * 2);
		speed = new Vec2D(0.0 , 0.0);
		direction = 0;
		
		playerdata = gamemain.playerdata;
		life = playerdata.life_max * LIFE_RATIO;
		field = gamemain.field;
		position = field.getStartPoint();
		jumped_point = new Vec2D(position.x , position.y);
		gamemain.view.setPosition(position);
		
		Hell_playBgm("resource/sound/ino1.ogg");
	}
	
	void move()
	{
		switch(state)
		{
		case STATE_START:			// 開始
			wait_timer++;
			if(wait_timer > START_WAIT_INTERVAL) state = STATE_NORMAL;
			break;
			
		case STATE_NORMAL:			// 通常
			moveByInput();
			moveNormal();
			
			// ライフ自動回復
			if(life < playerdata.life_max * LIFE_RATIO){
				int o_life = life;
				life++;
				if(life / LIFE_RATIO != o_life / LIFE_RATIO) Hell_playWAV("heal");
			}
			
			break;
			
		case STATE_ITEMGET:			// アイテム取ったどー!
			moveItemGet();
			
			// クリアチェック
			if(playerdata.isGameClear() && state != STATE_ITEMGET) gamemain.setMsg(GameMain.MSG_REQ_ENDING);
			
			break;
			
		case STATE_MUTEKI:			// 無敵時間
			moveByInput();
			moveNormal();
			
			wait_timer++;
			if(wait_timer > MUTEKI_INTERVAL) state = STATE_NORMAL;
			break;
			
		case STATE_DEAD:			// 死亡
			moveNormal();
			
			Hell_stopBgm(0);
			if(isPushEnter() && wait_timer > 15) gamemain.setMsg(GameState.MSG_REQ_TITLE);
			break;
		default:
			break;
		}
		if(life < LIFE_RATIO){			// 死亡
			if(state != STATE_DEAD) wait_timer = 0;
			state = STATE_DEAD;
			direction = 0;
			wait_timer++;
		}
	}
	void moveNormal(){
		timer++;
		playerdata.playtime = (timer / 50);
		
		// 移動＆落下
		speed.y += PLAYER_GRAVITY;
		position += speed;
		if(speed.y > PLAYER_FALL_SPEEDMAX) speed.y = PLAYER_FALL_SPEEDMAX;
		
		if(state == STATE_NORMAL) checkCollision();
		
		// ATARI判定
		bool hitLeft = false , hitRight = false , hitUpper = false;
		if(onWall() && speed.y >= 0){			// 着地判定
			if(playerdata.lunker_mode){	// ランカー・モード
				if(position.y - jumped_point.y > LUNKER_JUMP_DAMAGE1){
					state = STATE_MUTEKI;
					wait_timer = 0;
					life -= LIFE_RATIO;
					Hell_playWAV("damage");
				}
				if(position.y - jumped_point.y > LUNKER_JUMP_DAMAGE2){
					state = STATE_MUTEKI;
					wait_timer = 0;
					life -= LIFE_RATIO * 99;
					Hell_playWAV("damage");
				}
			}
			
			if(isPressEnter() && isPressDown() && isFallable()){
				// 落下
			}else{
				if(speed.y > 0) speed.y = 0;
				position.y = CHAR_SIZE * toFieldY();
				jump_cnt = 0;
			}
			
			jumped_point.x = position.x;
			jumped_point.y = position.y;
		}
		if(isLeftWall() && speed.x < 0) hitLeft = true;		// 左壁
		if(isRightWall() && speed.x > 0) hitRight = true;	// 右壁
		if(isUpperWall() && speed.y <= 0) hitUpper = true;	// 上壁
		
		
		if(hitUpper && !hitLeft && !hitRight)	normalizeToUpper();
		if(!hitUpper && hitLeft)		normalizeToLeft();
		if(!hitUpper && hitRight) 		normalizeToRight();
		if(hitUpper && hitRight){
			if(isUpperWallBoth()){
				normalizeToUpper();
			}else{
				if(toFieldOfsX() > toFieldOfsY()){
					normalizeToRight();
				}else{
					normalizeToUpper();
				}
			}
		}
		if(hitUpper && hitLeft){
			if(isUpperWallBoth()){
				normalizeToUpper();
			}else{
				if(CHAR_SIZE - toFieldOfsX() > toFieldOfsY()){
					normalizeToLeft();
				}else{
					normalizeToUpper();
				}
			}
		}
		
		// 床特殊効果
		switch(getOnField()){
		case Field.FIELD_SCROLL_L:
			speed.x = speed.x * (1.0 - PLAYER_GRD_ACCRATIO) + (direction * PLAYER_SPEED - Field.SCROLLPANEL_SPEED) * PLAYER_GRD_ACCRATIO;
			break;
		case Field.FIELD_SCROLL_R:
			speed.x = speed.x * (1.0 - PLAYER_GRD_ACCRATIO) + (direction * PLAYER_SPEED + Field.SCROLLPANEL_SPEED) * PLAYER_GRD_ACCRATIO;
			break;
		case Field.FIELD_SLIP:
			break;
		case  Field.FIELD_NONE:
			speed.x = speed.x * (1.0 - PLAYER_AIR_ACCRATIO) + direction * PLAYER_SPEED * PLAYER_AIR_ACCRATIO;
			break;
		default:
			speed.x = speed.x * (1.0 - PLAYER_GRD_ACCRATIO) + direction * PLAYER_SPEED * PLAYER_GRD_ACCRATIO;
			break;
		}
		
		// ビューの更新
		Vec2D v = gamemain.view.getPosition();
		v.x = v.x * 0.95 + (position.x + speed.x * VIEW_DIRECTION_OFFSET) * 0.05;
		v.y = v.y * 0.95 + position.y * 0.05;
		gamemain.view.setPosition(v);
	}
	
	void moveItemGet(){
		if(wait_timer < WAIT_TIMER_INTERVAL){
			wait_timer ++;
			return;
		}
		
		if(isPushEnter()){
			state = STATE_NORMAL;
			
			Hell_playBgm("resource/sound/ino1.ogg");
		}
	}
	void moveByInput(){
		if(isPressLeft()) direction = -1;
		if(isPressRight()) direction = 1;
		if(isPushEnter() &&(playerdata.jump_max > jump_cnt || onWall())&& !isPressDown()){	
			speed.y = PLAYER_JUMP;		// ジャンプ
			if(!onWall()) jump_cnt++;
			
			if(fabs(speed.x) < 0.1){
				if(speed.x < 0)speed.x -= 0.02;
				if(speed.x > 0)speed.x += 0.02;
			}
			
			Hell_playWAV("jump");
			
			jumped_point.x = position.x;
			jumped_point.y = position.y;
		}
		
	}
	
	// 各種接触処理
	void checkCollision(){
		for(int xx=0;xx<2;xx++){
			for(int yy=0;yy<2;yy++){
				// アイテム獲得(STATE_ITEMGETへ遷移)
				if(field.isItem(toFieldX() + xx,toFieldY() + yy)){
					// 隠しアイテムは条件が必要
					if(!field.isItemGetable(toFieldX() + xx , toFieldY() + yy)) continue;
					
					state = STATE_ITEMGET;
					
					// アイテム効果
					item_get = field.getField(toFieldX() + xx , toFieldY() + yy);
					switch(field.getField(toFieldX() + xx , toFieldY() + yy))
					{
						case Field.FIELD_ITEM_POWERUP:
							playerdata.jump_max++;
							break;
						case Field.FIELD_ITEM_LIFE:
							playerdata.life_max++;
							life = playerdata.life_max * LIFE_RATIO;
							break;
						default:
							playerdata.itemGetFlag[item_get] = true;
							break;
					}
					field.eraseField(toFieldX() + xx,toFieldY() + yy);
					wait_timer = 0;
					
					Hell_stopBgm(0);
					if(playerdata.isItemForClear(item_get) || item_get == Field.FIELD_ITEM_POWERUP){
						Hell_playWAV("itemget");
					}else{
						Hell_playWAV("itemget2");
					}
					return;
				}
				// トゲ(ダメージ)
				if(field.isSpike(toFieldX() + xx,toFieldY() + yy)){
					state = STATE_MUTEKI;
					wait_timer = 0;
					life -= LIFE_RATIO;
					speed.y = PLAYER_JUMP;
					jump_cnt = -1;			// ダメージ・エキストラジャンプ
					
					Hell_playWAV("damage");
					
					return;
				}
			}
		}
	}
	
	// 乗っているものを返す
	int getOnField(){
		if(!onWall())return Field.FIELD_NONE;
		if(toFieldOfsX() < CHAR_SIZE / 2){
			if(field.isRidable( toFieldX()	  ,toFieldY() + 1 )){
				return field.getField( toFieldX() , toFieldY() + 1);
			}else{
				return field.getField( toFieldX() + 1 , toFieldY() + 1);
			}
		}else{
			if(field.isRidable( toFieldX() + 1,toFieldY() + 1 )){
				return field.getField( toFieldX() + 1 , toFieldY() + 1);
			}else{
				return field.getField( toFieldX() , toFieldY() + 1);
			}
		}
	}
	
	bool onWall(){			// 壁に乗っているか
		if(toFieldOfsY() > CHAR_SIZE / 4) return false;
		if(field.isRidable( toFieldX()	,toFieldY() + 1 ) && toFieldOfsX() < CHAR_SIZE * 7 / 8)	return true;
		if(field.isRidable( toFieldX() + 1	,toFieldY() + 1 ) && toFieldOfsX() > CHAR_SIZE / 8)	return true;
		return false;
	}
	bool isFallable(){		// 落ちれるか
		if(!onWall()) return false;
		if(field.isWall( toFieldX()	,toFieldY() + 1 ) && toFieldOfsX() < CHAR_SIZE * 7 / 8)	return false;
		if(field.isWall( toFieldX() + 1	,toFieldY() + 1 ) && toFieldOfsX() > CHAR_SIZE / 8)	return false;
		return true;
	}
	bool isUpperWallBoth(){		// 頭上確認(２マスとも壁)
		if(toFieldOfsY() < CHAR_SIZE / 2) return false;
		if(field.isWall( toFieldX()	,toFieldY() 	) && field.isWall( toFieldX() + 1	,toFieldY()	))	return true;
		return false;
	}
	bool isUpperWall(){		// 頭上確認
		if(toFieldOfsY() < CHAR_SIZE / 2) return false;
		if(field.isWall( toFieldX()	,toFieldY() 	) && toFieldOfsX() < CHAR_SIZE * 7 / 8)	return true;
		if(field.isWall( toFieldX() + 1	,toFieldY()	) && toFieldOfsX() > CHAR_SIZE / 8)	return true;
		return false;
	}
	bool isLeftWall(){		// 左壁確認
		if(field.isWall( toFieldX()	,toFieldY() 	))	return true;
		if(field.isWall( toFieldX()	,toFieldY() + 1	) && toFieldOfsY() > CHAR_SIZE / 8)	return true;
		return false;
	}
	bool isRightWall(){		// 右壁確認
		if(field.isWall( toFieldX() + 1	,toFieldY() 	))	return true;
		if(field.isWall( toFieldX() + 1	,toFieldY() + 1	) && toFieldOfsY() > CHAR_SIZE / 8)	return true;
		return false;
	}
	
	void normalizeToRight(){	// 右壁にあたって停止
		position.x = toFieldX() * CHAR_SIZE;
		speed.x = 0;
	}
	void normalizeToLeft(){		// 左壁にあたって停止
		position.x = (toFieldX() + 1) * CHAR_SIZE;
		speed.x = 0;
	}
	void normalizeToUpper(){	// 上壁にあたって停止
		if(speed.y < 0) speed.y = 0;
		position.y = CHAR_SIZE * (toFieldY() + 1);
	}
	
	// フィールドマップ座標系へ変換
	int toFieldX(){return cast(int)(position.x / CHAR_SIZE);}
	int toFieldY(){return cast(int)(position.y / CHAR_SIZE);}
	// フィールドマップ座標系変換の余り
	int toFieldOfsX(){return cast(int)position.x % CHAR_SIZE;}
	int toFieldOfsY(){return cast(int)position.y % CHAR_SIZE;}
	
	// 作画
	void draw()
	{
		Vec2D v = gamemain.view.toScreenPosition(position);
		if(state == STATE_DEAD){					// 死亡
			int anime = ((timer / 6) % 4);
			if(playerdata.lunker_mode){
				Hell_draw("ino" , cast(int)v.x , cast(int)v.y , CHAR_SIZE * (2 + anime) , 128 + CHAR_SIZE * 2 , CHAR_SIZE,CHAR_SIZE);
			}else{
				Hell_draw("ino" , cast(int)v.x , cast(int)v.y , CHAR_SIZE * (2 + anime) , 128 , CHAR_SIZE,CHAR_SIZE);
			}
		}else{								// 生存
			if(state != STATE_MUTEKI || timer % 10 < 5){
				int anime = ((timer / 6) % 2);
				if(!onWall()) anime = 0;
				if(direction < 0){
					if(playerdata.lunker_mode){
						Hell_draw("ino" , cast(int)v.x , cast(int)v.y , CHAR_SIZE * anime , 128 + CHAR_SIZE * 2 , CHAR_SIZE,CHAR_SIZE);
					}else{
						Hell_draw("ino" , cast(int)v.x , cast(int)v.y , CHAR_SIZE * anime , 128 , CHAR_SIZE,CHAR_SIZE);
					}
				}else{
					if(playerdata.lunker_mode){
						Hell_draw("ino" , cast(int)v.x , cast(int)v.y , CHAR_SIZE * anime , 128 + CHAR_SIZE * 3 , CHAR_SIZE,CHAR_SIZE);
					}else{
						Hell_draw("ino" , cast(int)v.x , cast(int)v.y , CHAR_SIZE * anime , 128 + CHAR_SIZE , CHAR_SIZE,CHAR_SIZE);
					}
				}
			}
		}
		/*	// でばぐ
		Hell_drawFont(" I:" ~ std.string.toString(playerdata.getItemCount()) , 0,16);
		Hell_drawFont(" J:" ~ std.string.toString(jump_cnt) ~ " MJ:" ~ std.string.toString(jump_max) , 0,9);
		Hell_drawFont(" X:" ~ std.string.toString(cast(int)position.x) ~ " FX:" ~ std.string.toString(toFieldX()) ~ " OX:" ~ std.string.toString(toFieldOfsX()) , 0,18);
		Hell_drawFont(" Y:" ~ std.string.toString(cast(int)position.y) ~ " FY:" ~ std.string.toString(toFieldY()) ~ " OY:" ~ std.string.toString(toFieldOfsY()) , 0,27);
		*/
		
		// ライフ表示
		for(int t=0;t<playerdata.life_max;t++){
			if(life < LIFE_RATIO * 2 && timer % 10 < 5 && playerdata.life_max > 1) continue;
			
			if(life >= (t + 1) * LIFE_RATIO){
				Hell_draw("ino" , CHAR_SIZE * t , 0 , CHAR_SIZE * 3 , 128 + CHAR_SIZE * 1 , CHAR_SIZE,CHAR_SIZE);
			}else{
				Hell_draw("ino" , CHAR_SIZE * t , 0 , CHAR_SIZE * 4 , 128 + CHAR_SIZE * 1 , CHAR_SIZE,CHAR_SIZE);
			}
		}
		
		// 取ったアイテム一覧
		for(int t=Field.FIELD_ITEM_FUJI ; t<Field.FIELD_ITEM_MAX ; t++){
			if(!playerdata.itemGetFlag[t] || (playerdata.isItemForClear(t) && timer % 10 < 5)){
				Hell_draw("ino" , g_width - CHAR_SIZE / 4 * (Field.FIELD_ITEM_MAX - 2 - t) , 0 ,	// 無
						CHAR_SIZE * 5 , 128 + CHAR_SIZE , CHAR_SIZE / 4 , CHAR_SIZE / 2);
			}else{
				Hell_draw("ino" , g_width - CHAR_SIZE / 4 * (Field.FIELD_ITEM_MAX - 2 - t) , 0 ,	// 有
						CHAR_SIZE * 5 + CHAR_SIZE / 4 , 128 + CHAR_SIZE  , CHAR_SIZE / 4 , CHAR_SIZE / 2);
			}
		}
		
		
		// アイテム獲得メッセージ
		if(state == STATE_ITEMGET){
			int t = WAIT_TIMER_INTERVAL - wait_timer;
			Hell_draw("msg" , (g_width - 256) / 2 , (g_height - 96) / 2 - t * t + 24 ,
					256 , 96 * (item_get - Field.FIELD_ITEM_BORDER - 1), 256 , 96);
			Hell_fillRect((g_width - 32) / 2 , (g_height - 96) / 2 - t * t - 24 ,32,32,0,0,0);
			Hell_fillRect((g_width - 32) / 2  + 2, (g_height - 96) / 2 - t * t - 24 + 2,32 - 4,32 - 4,255,255,255);
			
			int it = item_get - (Field.FIELD_ITEM_BORDER + 1);
			Hell_draw("ino" , (g_width - 16) / 2 , (g_height - 96) / 2 - t * t - 16 ,
					(it % 16) * CHAR_SIZE, (it / 16 + 4) * CHAR_SIZE , CHAR_SIZE , CHAR_SIZE);
		}
		
		// ゲーム開始メッセージ
		if(state == STATE_START) Hell_draw("msg", (g_width - 256) / 2 ,  64 , 0 , 96 , 256 , 32);
		// ゲームオーバーメッセージ
		if(state == STATE_DEAD) Hell_draw("msg", (g_width - 256) / 2 ,  64 , 0 , 128 , 256 , 32);
	}
}

// ビュー。スクリーン座標の中心およびスクリーン座標系への変換を担当
class View
{
public:
	Vec2D position;
	
	this(){position = new Vec2D(0 , 0);}
	
	Vec2D toScreenPosition(Vec2D v)
	{
		return new Vec2D(v.x - position.x + g_width / 2 , v.y - position.y + g_height / 2);
	}
	Vec2D getPosition(){return new Vec2D(position);}
	void setPosition(Vec2D v){position.x = v.x;position.y = v.y;}
}

class GameMain : GameState
{
public:
	Player player;
	View view;
	Field field;
	PlayerData playerdata;
	
	int msg;
	
	this(PlayerData pd)
	{
		playerdata = pd;
		view = new View();
		field = new Field(this);
		player = new Player(this);
		
		msg = MSG_NONE;
	}
	
	void update()
	{
		field.move();
		player.move();
	}
	
	void draw()
	{
		Hell_fillRect(0,0,g_width,g_height,255,255,255);
		field.draw();
		player.draw();
	}
}

class PlayerData
{
public:
	bool itemGetFlag[Field.FIELD_ITEM_MAX];
	int playtime;
	int jump_max;
	int life_max;
	bool lunker_mode;
	
	static const int CLEAR_FLAG_ITEM[] = [
		Field.FIELD_ITEM_FUJI , Field.FIELD_ITEM_TAKA , Field.FIELD_ITEM_NASU
	];
	
	enum{
		GAMEMODE_NORMAL,
		GAMEMODE_LUNKER,
	}
	
	this(){init(GAMEMODE_NORMAL);}
	
	void init(int gm)
	{
		for(int t=0;t<Field.FIELD_ITEM_MAX;t++) itemGetFlag[t] = false;
		playtime = 0;
		jump_max = 0;
		
		switch(gm){
		case GAMEMODE_NORMAL:
			// ノーマルモード
			life_max = 3;
			lunker_mode = false;
			break;
		case GAMEMODE_LUNKER:
			// ランカー・モード
			life_max = 1;
			lunker_mode = true;
			jump_max = 1;		// 追加最大ジャンプ
			break;
		default:
			life_max = 3;
			lunker_mode = false;
			break;
		}
	}
	
	bool isGameClear()
	{
		bool f = true;
		foreach(t;CLEAR_FLAG_ITEM) if(!itemGetFlag[t]) f = false;
		return f;
	}
	
	bool isItemForClear(int it)
	{
		foreach(t;CLEAR_FLAG_ITEM) if(t == it) return true;
		return false;
	}
	
	int getItemCount()
	{
		int f = 0;
		foreach(t;itemGetFlag) if(t) f++;
		
		return f;
	}
}
//------------------------------------------------------------------------------
// 下位状態管理 / ゲームメイン以外の状態処理
//------------------------------------------------------------------------------

// タイトル
class TitleMain : GameState
{
public:
	int timer;
	int offset_x = 0 , offset_y = 0;
	
	int lunker_command;
	static bool islunker = false;
	
	this()
	{
		timer = 0;
		lunker_command = 0;
		
		Hell_stopBgm(0);
	}
	
	void update()
	{
		timer++;
		if(timer % 5 == 0){
			offset_x = (rand() / 11) % 5 - 3;
			offset_y = (rand() / 11) % 5 - 3;
		}
		
		if(isPushEnter() && timer > 5){
			setMsg(MSG_REQ_OPENING);
			
			if(islunker){
				g_playerdata.init(PlayerData.GAMEMODE_LUNKER);
			}else{
				g_playerdata.init(PlayerData.GAMEMODE_NORMAL);
			}
		}
		
		// ランカー・モード・コマンド
		switch(lunker_command){
		case 0,1,2,6:
			if(isPushLeft()){
				lunker_command++;
			}else if(isPushRight() || isPushUp() || isPushDown()){
				lunker_command = 0;
			}
			break;
		case 3,4,5,7:
			if(isPushRight()){
				lunker_command++;
			}else if(isPushLeft() || isPushUp() || isPushDown()){
				lunker_command = 0;
			}
			break;
		default:
			break;
		}
		if(lunker_command > 7){
			lunker_command = 0;
			islunker = !islunker;
		}
	}
	
	void draw()
	{
		if(islunker){
			Hell_fillRect(0,0,g_width,g_height,0,0,0);
		}else{
			Hell_fillRect(0,0,g_width,g_height,255,255,255);
		}
		Hell_draw("msg", (g_width - 256) / 2 ,  32 , 0 , 0 , 256 , 64);
		Hell_draw("msg", (g_width - 256) / 2 + offset_x  , 160 + offset_y , 0 , 64 , 256 , 32);
	}
}

// オープニング
class OpeningMain : GameState
{
public:
	int timer;
	static const int SCROLL_LEN = 416;
	static const int SCROLL_SPEED = 3;
	
	this()
	{
		Hell_playBgm("resource/sound/ino2.ogg");
	}
	
	void update()
	{
		timer++;
		if(isPressDown()) timer+=5;
		if((isPushEnter() && timer > 5)|| timer / SCROLL_SPEED > SCROLL_LEN + g_height){
			setMsg(MSG_REQ_GAME);
			
			Hell_stopBgm(0);
		}
	}
	
	void draw()
	{
		Hell_fillRect(0,0,g_width,g_height,255,255,255);
		
		Hell_draw("msg" , (g_width - 256) / 2 , g_height - (timer / SCROLL_SPEED) ,
				0 , 160, 256 , SCROLL_LEN);
	}
}

// エンディング
class EndingMain : GameState
{
public:
	int timer;
	int state;
	
	PlayerData playerdata;
	
	static const int SCROLL_LEN = 1088;
	static const int SCROLL_SPEED = 3;
	
	enum{
		STATE_STAFFROLL,
		STATE_RESULT,
	}
	
	this(PlayerData pd){
		playerdata = pd;
		state = STATE_STAFFROLL;
		
		Hell_playBgm("resource/sound/ino2.ogg");
	}
	
	void update()
	{
		timer++;
		switch(state)
		{
		case STATE_STAFFROLL:
			if(isPressDown()) timer+=5;
			if((isPushEnter() && timer > 5)|| timer / SCROLL_SPEED > SCROLL_LEN + g_height){
				timer = 0;
				state = STATE_RESULT;
				
				Hell_stopBgm(5000);
			}
		case STATE_RESULT:
			if(isPushEnter() && timer > 5){
				// 条件を満たしていると隠し画面へ
				if(playerdata.itemGetFlag[Field.FIELD_ITEM_OMEGA]){
					if(playerdata.lunker_mode){
						setMsg(MSG_REQ_SECRET2);
					}else{
						setMsg(MSG_REQ_SECRET1);
					}
				}else{
					setMsg(MSG_REQ_TITLE);
				}
			}
		default:
			break;
		}
	}
	
	void draw()
	{
		Hell_fillRect(0,0,g_width,g_height,255,255,255);
		
		switch(state)
		{
		case STATE_STAFFROLL:
			Hell_draw("msg" , (g_width - 256) / 2 , g_height - (timer / SCROLL_SPEED) ,
				0 , 576, 256 , SCROLL_LEN);
			break;
		case STATE_RESULT:
			Hell_draw("msg" , (g_width - 256) / 2 , (g_height - 160) / 2 ,
				0 , 1664 , 256 , 160);
				
			Hell_drawFont(std.string.toString(playerdata.getItemCount()) ,
				 (g_width - 10 * 0)/ 2,  (g_height - 160) / 2 + 13 * 5 + 2);
				 
			Hell_drawFont(std.string.toString(playerdata.playtime) , (g_width - 13)/ 2 ,  (g_height - 160) / 2 + 13 * 8 + 2);
			
			break;
		default:
			break;
		}
	}
}

// 隠し画面
class SecretMain : GameState
{
public:
	int number;
	int timer;
	
	PlayerData playerdata;
	
	this(PlayerData pd,int n){
		playerdata = pd;
		number = n;
		timer = 0;
	}
	
	void update()
	{
		timer++;
		if(isPushEnter() && timer > 5) setMsg(MSG_REQ_TITLE);
	}
	
	void draw()
	{
		Hell_fillRect(0,0,g_width,g_height,0,0,0);
		
		if(number == 1){
			Hell_draw("msg" , (g_width - 256) / 2 , (g_height - 96) / 2 ,
				0 , 2048 - 96 * 2 , 256 , 96);
		}else{
			Hell_draw("msg" , (g_width - 256) / 2 , (g_height - 96) / 2 ,
				0 , 2048 - 96 , 256 , 96);
		}
	}
}


// 状態のスーパークラス
class GameState{
public:
	enum{
		MSG_NONE,		// なし
		MSG_REQ_TITLE,		// たいとるに　行きたい！
		MSG_REQ_GAME,		// げーむに　行きたい！
		MSG_REQ_OPENING,	// おーぷにんぐに　行きたい！
		MSG_REQ_ENDING,		// えんでぃんぐに　行きたい！
		MSG_REQ_SECRET1,	// かくしがめん1に　行きたい！
		MSG_REQ_SECRET2,	// かくしがめん2に　行きたい！
	}
	int msg;			// 状態遷移メッセージ
	
	this(){msg = MSG_NONE;}
	
	void update(){}
	void draw(){}
	
	int getMsg(){return msg;}
	void setMsg(int m){msg = m;}
}

GameState g_gamestate = null;
PlayerData g_playerdata = null;


// メインループ
void loop(){
	if(g_gamestate){
		switch(g_gamestate.getMsg())		// 状態遷移メッセージを受け取る
		{
		case GameState.MSG_REQ_TITLE:
			g_gamestate = new TitleMain();
			break;
		case GameState.MSG_REQ_OPENING:
			g_gamestate = new OpeningMain();
			break;
		case GameState.MSG_REQ_GAME:
			g_gamestate = new GameMain(g_playerdata);
			break;
		case GameState.MSG_REQ_ENDING:
			g_gamestate = new EndingMain(g_playerdata);
			break;
		case GameState.MSG_REQ_SECRET1:
			g_gamestate = new SecretMain(g_playerdata , 1);
			break;
		case GameState.MSG_REQ_SECRET2:
			g_gamestate = new SecretMain(g_playerdata , 2);
			break;
		default:
			break;
		}
	}else{
		g_playerdata = new PlayerData();
		g_gamestate = new TitleMain();		// 初期状態
	}
	
	g_gamestate.draw();
	g_gamestate.update();
}

//------------------------------------------------------------------------------
// 下位システム
//------------------------------------------------------------------------------

bool isPressEnter()
{
	if(Hell_isPressKey(HELL_z)) return true;
	if(Hell_isPressKey(HELL_SPACE)) return true;
	if(Hell_isPressJButton(0))  return true;
	return false;
}
bool isPushEnter()
{
	if(Hell_isPushKey(HELL_z)) return true;
	if(Hell_isPushKey(HELL_SPACE)) return true;
	if(Hell_isPushJButton(0))  return true;
	return false;
}
bool isPushCancel()
{	
	if(Hell_isPushKey(HELL_x)) return true;
	if(Hell_isPushJButton(1))  return true;
	return false;
}
bool isPressLeft()
{
	if(Hell_isPressKey(HELL_LEFT))    return true;
	if(Hell_isPressJKey(HELL_J_LEFT)) return true;
	return false;
}
bool isPressUp()
{
	if(Hell_isPressKey(HELL_UP))    return true;
	if(Hell_isPressJKey(HELL_J_UP)) return true;
	return false;
}
bool isPressRight()
{
	if(Hell_isPressKey(HELL_RIGHT))    return true;
	if(Hell_isPressJKey(HELL_J_RIGHT)) return true;
	return false;
}
bool isPressDown()
{
	if(Hell_isPressKey(HELL_DOWN))    return true;
	if(Hell_isPressJKey(HELL_J_DOWN)) return true;
	return false;
}
bool isPushLeft()
{
	if(Hell_isPushKey(HELL_LEFT))    return true;
	if(Hell_isPushJKey(HELL_J_LEFT)) return true;
	return false;
}
bool isPushUp()
{
	if(Hell_isPushKey(HELL_UP))    return true;
	if(Hell_isPushJKey(HELL_J_UP)) return true;
	return false;
}
bool isPushRight()
{
	if(Hell_isPushKey(HELL_RIGHT))    return true;
	if(Hell_isPushJKey(HELL_J_RIGHT)) return true;
	return false;
}
bool isPushDown()
{
	if(Hell_isPushKey(HELL_DOWN))    return true;
	if(Hell_isPushJKey(HELL_J_DOWN)) return true;
	return false;
}

// リソースの読み込み
void load()
{
	Hell_loadBMP("ino","resource/image/ino.bmp",-1);
	Hell_loadBMP("msg","resource/image/msg.bmp",-1);
	
	Hell_loadWAV("heal", "resource/sound/heal.wav");
	Hell_loadWAV("itemget", "resource/sound/itemget.wav");
	Hell_loadWAV("itemget2", "resource/sound/itemget2.wav");
	Hell_loadWAV("damage", "resource/sound/damage.wav");
	Hell_loadWAV("jump", "resource/sound/jump.wav");
}

// ヘルライブラリ・エントリポイント
int Hell_main(char[][] args)
{
	try
	{
		Hell_init("INO-vation 2007", g_width, g_height);
		load();
		while(true)
		{
			loop();
			Hell_update();
			Hell_wait(20); // 50fps
		}
	}
	catch(Exception e)
	{
		Hell_write(e);
	}
	finally
	{
		Hell_quit();
	}
	
	return 0;
}

// コンソールを消すおまじない
version (Win32_release)
{
	private import std.c.windows.windows;
	private import std.string;

	extern (C) void gc_init();
	extern (C) void gc_term();
	extern (C) void _minit();
	extern (C) void _moduleCtor();

	extern (Windows)
	public int WinMain(HINSTANCE hInstance,
		HINSTANCE hPrevInstance,
		LPSTR lpCmdLine,
		int nCmdShow)
	{
		int result;
		gc_init();
		_minit();
		try
		{
			_moduleCtor();
			char exe[4096];
			GetModuleFileNameA(null, cast(char*)exe, 4096);
			char[][1] prog;
			prog[0] = std.string.toString(toStringz(exe));
			result  = Hell_main(prog ~ std.string.split(std.string.toString(lpCmdLine)));
		}
		catch(Object o)
		{
			printf(std.string.toStringz(o.toString()));
			result = 1;
		}
		gc_term();
		return result;
	}
}
else
{
	public int main(char[][] args)
	{
		return Hell_main(args);
	}
}

version (Darwin)
{
        extern (C) int _d_run_Dmain(int argc, char* argv[]);
        extern (C) int SDL_main(int argc, char* argv[]) {
                return _d_run_Dmain(argc, argv);
        }
}
