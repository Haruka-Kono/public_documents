# AutoDock-Vinaを用いたドッキングシミュレーションマニュアル（保存用）

# はじめに
本マニュアルは，AutoDock Vinaというドッキングシミュレーションソフトを用いてタンパク質とリガンドのドッキングシミュレーションを行う方法について説明したものです．ちなみに，マニュアル本体は[https://github.com/Haruk-Kono/public_documents/wiki](https://github.com/Haruk-Kono/public_documents/wiki) にあります．もしかしたら更新するかもしれないので最新版はリンクを参照してもらえると幸いです．
何か質問がありましたら，マニュアル監修者にメールください（kono.h.ab@m.titech.ac.jp）．　2019年3月某日　河野（2016年度尾形研卒）

# AutoDock Vinaとは
Scripps Research InstituteのTrottらによって開発されたフリーのドッキングシミュレーションソフトウェアで，Windows，Mac，Linuxに対応しています．ドッキングシミュレーションを行うためには，レセプターとリガンドそれぞれのの立体構造を記述した，**pdbqt**という形式のファイルが必要になります．pdbqtフォーマットは，タンパク質などの立体構造を表記するファイル形式であるPDBフォーマットをベースとした，AutodockおよびAutodock Vina専用のファイル形式であり，原子ごとの電荷，原子タイプ，そして自由回転が可能な分子及びその結合を表す"flexible molecule"についての情報が追加されています．また，ドッキング時のリガンド結合領域は，**Grid Box**と呼ばれる直方体によって指定されます．

# AutoDock Vinaによるドッキングシミュレーション

## ドッキングに必要なファイル等
- レセプターのpdbqtファイル
- リガンドのpdbqtファイル
- Grid Boxの指定
- ドッキング条件などの設定ファイル（configファイル）

## 使用ソフト
以下すべて研究室のワークステーションに導入済ソフトウェアのため，インストール手順等は省略します．時間があったら，自分用の記録もかねて導入マニュアルを別途作成するかもしれないです．その際はこのマニュアルと同じ[https://github.com/Haruk-Kono/public_documents/wiki](https://github.com/Haruk-Kono/public_documents/wiki) に，本マニュアルとは別ページ扱いで載せます．
- AutoDock Vina（ドッキングシミュレーション実行ソフト）
- AutoDockTools（レセプター，リガンドのpdbqtファイル等の作成用）
- PyMOL（分子描画ソフト．今回はレセプターやリガンド構造の下準備，Grid Box設定および結果の確認等に使う）
- PyMOL AutoDock/Vina Plugin（PyMOLに入れるAutoDock Vinaのプラグイン．Grid Box設定に使う）
- Avogadro（リガンドの構造作成に使う）
- MOPAC 2016（リガンド構造最適化用）
- cygwin（シミュレーション用のプログラムを動かすために使う）

## 具体的なドッキングシミュレーション手順（リゾチームとGalGN3Dのドッキングシミュレーションを例に）
今回は，かつて実際に行った，リゾチームとGalGN3Dとのドッキングシミュレーション（[Ogata, M. et al., 2017](https://doi.org/10.1016/j.ab.2017.09.015)）を例にして手順を説明していきます．そのため，ドッキングする対象化合物によってはここに書いてある手順じゃないことをする場合がありますがそこはご容赦願います．また，当時の手順と全く同じではないのでそこもご容赦願います．特にリガンドの作り方は，手に入るデータや構造次第でやり方が何通りもあるのですが，多分ある程度ドッキングに慣れてきたら対処できるはず...です．　

### 前提条件（フォルダ構成など）
以下のようなフォルダ構成になっていることを前提として手順を説明していきます．尾形研のワークステーションでシミュレーションをする場合，条件をすでに満たしているので気にしなくて大丈夫です．

```
C:\
└─vina\
    | vinaforcygwin2.sh
    | vina.exe
    | vina_split.exe
    |
    ├─config\ 
    ├─dock_result\
    ├─pdbqt_ligand\
    ├─pdb_ligand\
    ├─receptor_pdb\
    └─receptor_pdbqt\

```

### 1. Grid Boxの設定とレセプターのPDBファイル作成（PyMOL，PyMOL-AutoDock/Vina Plugin を使用）
リガンドの結合範囲を指定するGrid Boxと呼ばれる箱を設定します．同時にレセプター分子（今回はリゾチーム）のPDBファイルも用意します．少々面倒かもしれませんが，レセプターやGrid Boxは一度設定すれば大抵使いまわしが効きます．なお，今回用いるリゾチームのPDB IDは4HP0です．

①**PyMOLの起動**
windowsタスクバーの検索窓に```pymol```と入力し，```PyMOL+Tcl-Tk GUI (legacy)```を起動します（下図）．

※本来は下図の上に出ているPyMOLが使いやすくていいのですが，AutoDockのプラグインがそちらだとうまく動かないため，本操作に限ってはlegacyの方を利用します．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_legacy_forGridBox.PNG" width="450px">

こんな感じの画面が出てきます．ウィンドウは上（The PyMOL Molecular Graphics System）と下（PyMOL Viewer）がバラバラになっており，ちょっとめんどくさいです．legacyではない通常のPyMOLはウィンドウが一体化しています．Grid Boxの設定が絡んでこない場合はそちらを使うのが楽です．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_legacy_view.PNG" width="500px">


***

②**リゾチーム（PDB ID: 4HP0）の読み込み**
上の方にある入力窓（下図参照）に，``` fetch 4HP0 ``` と入力-> ```Enter``` 
legacyバージョンのPyMOLはIDのアルファベットを大文字にしないと認識してくれないのでそこは注意してください．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_legacy_fetch.PNG" width="500px">


***

③**水分子の除去**
先ほどの操作でリゾチームの立体構造が下図のように表示されると思います．これはリゾチームとキチンオリゴ糖誘導体（GN3M）との共結晶です．今回のシミュレーションでは，GN3Mの代わりにGalGN3Dをドッキングさせるため，GN3Mは後ほど除去しますが，Grid Boxを設定するまではそのままにしておきます．周りにある赤い点たちは水分子です．見た目にも邪魔なうえ，水分子があるとドッキングでエラーが起こるためにこれらを消去します．PyMOL Viewer内の右側，```4HP0```というパネルの隣にある```A```をクリックします（下図赤丸参照）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_13.PNG" width="640px">　

```Action```ウィンドウが開くので，```remove water```をクリックし，水分子を除去します．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_2.PNG" width="300px">

***

**④AutoDock Pluginを用いたGrid Boxの表示**

PyMOL上側のウィンドウにて，```Plugin```→```AutoDock/Vina```とクリックしていくとAutoDock/Vinaプラグインのウィンドウが出てきます．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_3.PNG" width="300px">

プラグインのウィンドウ上部にある```Grid Settings```タブをクリックし，```Grid Definition```>```Parameters```の```Spacing```を**1**に設定します．
（**注: この時横にある矢印ボタンやスクロールバーを使って数値を変えようとするとエラーが出ます！今後変更していくほかのパラメータも含め，このプラグインで数値を変えるときは手入力でやってください）**

設定後，右にある```Show Box```をクリックすると，PyMOL ViewerにGrid Boxが表示されます（下図1-4参照）箱が大きすぎてリゾチームがすっぽりと入っていることが見て取れます．実際は基質結合クレフトのあたりを覆うくらいの箱で十分なので，次の手順でGrid Boxの調整をしていきます．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_4.PNG" width="600px">


***

**⑤Grid Boxの調整**
まずBoxの中心をリガンド結合部位のちょうどいいところに持ってきます（ここら辺の位置調整に厳密なルールはないので，自分なりの微調整が必要になってきますが，これは慣れていくしかないです）．PyMOL Viewerにてリガンド分子をクリックします（下図１参照）．すると，Viewerの```(sele)```パネルに選択したリガンドが紐づけられます．

AutoDock/Vinaプラグインに戻り，```Calculate Grid Center by Selection```の入力欄に**sele**と入力します．その後，```Show Box```をクリックするとBoxの位置が更新され，中心が選択したリガンドのところに来ます（下図2,3参照）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_5.PNG" width="640px">

次にBoxの大きさを調整していきます．AutoDock/Vinaプラグインの```Grid Definition```>```Parameters```にて，```X-points=18```, ```Y-points=30```, ```Z-points=15```と入力し，```Show Box```をクリックするとBoxの大きさが変わります（下図参照）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_6.PNG" width="640px">


***

**⑥レセプター分子の調整**
ここまでの手順でGrid Boxをそれっぽい大きさにすることはできましたが，レセプターであるリゾチームの結合領域からは少しずれています．リゾチームの結合領域は横長であるため，Boxと向きが合わないとこのようになってしまいます．**Grid Boxのパラメータで操作できるのは中心の座標と各辺のサイズのみであり，軸を回転させることはできない**ため，今回のケースではレセプターのリゾチーム自身を動かしてBoxに合わせていく必要があります．

PyMOL Viewerに戻り，右側の```4hp0```パネルから，```A```→```drag coordinates```を選択します（下図参照）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_14.PNG" width="300px">

分子をBoxに合わせていきます．```Shift + 左ドラッグ```で分子が回転，```Shift + 中ドラッグ```で分子が移動します．この2つを駆使してうまいこと結合部位をBoxに合わせてください（身もふたもない説明で申し訳ないですが，Boxがらみのパラメーター調整は経験を積んでいくしかないので...）．気を付ける点としては，**ドッキングシミュレーションの際，リガンドはBoxの範囲内でレセプターと相互作用する**ということです．そのため，ドッキングさせようとするリガンドの大きさを考え，結合部位にリガンドが収まるかどうかを気にして調整してみてください．下図のようにいい感じになったら，Viewer右側のパネルにある```Done```をクリックすると，```drag coordinates```モードが終了します．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_7.PNG" width="620px">

***

**⑦Grid Boxパラメータの記録**
これでGrid Boxがらみの設定は完了したので，最後にAutoDock/Vinaプラグインに戻り，Grid Boxのサイズ（```Grid Definition > X (Y, Z)-points```）および座標（```Grid Center Coordinates```）をメモしておきます．あるいはこのプラグイン画面をそのまま残しておきます（下図赤丸）．**これらの値は，後にconfigファイルに入力することになるので記録が消えないように注意してください**．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_8.PNG" width="500px">

***

**⑧レセプター分子の保存**
Grid Boxの設定は無事に終わったので，続いてはViewerに残されたレセプター分子の操作に戻ります．先ほどGrid Boxに合わせて分子の座標を変えているので，その状態を維持して保存します．

まず，PyMOLの上部ウィンドウにて，```Display``` → ```Seqence```を選択すると，Viewerにアミノ酸配列が表示されます（下図）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_9.PNG" width="600px">

Viewerウィンドウのアミノ酸配列部分をスクロールしていくと右端に**NOJ**, **NAG**があるはずです．これがリガンド分子になります．計4つあるのでドラッグして選択します（下図）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_10.PNG" width="500px">

選択した4分子のいずれか1か所を右クリックすると下図のようなパネルが出てくるので，```remove```を選択します．これでリガンド分子の除去が終わりました．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_11.PNG" width="300px">


これで水分子の除去，Boxに合わせた座標の変更およびリガンドの除去が終わったので，この状態でレセプターのPDBファイルを保存します．上部ウィンドウにて```File```→```Export Molecule```と選択します（下図）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_12.PNG" width="450px">

**下図の赤丸のように選択**し，```OK```をクリックします．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_regacy_prep_rec_15.PNG" width="450px">

その後は，C:\vina\receptor_pdb\にファイルを保存します．今回は，**4HP0_fordock.pdb**というファイル名で保存しました．


### 2. リガンド（GalGN3D）のPDBファイル作成（PyMOL，Avogadro，MOPAC2016を使用）
続いてはリガンド分子のPDBファイルを用意していきます．基本的に尾形研でドッキングをする場合，自前で合成した新規化合物をリガンドにする場合がほとんどだと思います．その場合，既存のデータベースをそのまま使うことはできないので，似たような構造のリガンドを基に構造をいじっていく必要があります．いじり方は色々あるのですが，今回はPDB ID: 3AYQのリガンドを基にしてGalGN3DのPDBファイルを作る方法について説明します．

***

**①PyMOLの起動（legacyじゃない方）**
今回はAutoDock/Vinaプラグインを使う必要がないので，せっかくですしlegacyではない方のPyMOLを使ってみることにします．こちらは上下でバラバラだったウィンドウが統合された他いくつかアップデートされており幾分使いやすくなっています．

タスクバーの検索窓に**pymol**と入力し，下図赤丸の方のPyMOLを選択します．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol.PNG" width="300px">

ライセンスについてウィンドウが出てきますが，```skip activation```をクリックすれば大丈夫です．すると下図のような画面が出てきます．legacyよりちょっとスタイリッシュになっています．前述の通り，ウィンドウも上下で結合されているので使いやすいです．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_2_x_view.PNG" width="620px">

***

**②リガンドのテンプレート（PDB ID: 3AYQ)の読み込み**
下図のように，PyMOLの入力窓にて```fetch 3ayq``` → ```Enter```とすると分子が表示されます．この3AYQもリゾチームとキチンオリゴ糖誘導体との複合体構造になっています．ちなみにこちらのPyMOLは大文字小文字を問わないので安心してください．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_fetch_3ayq.PNG" width="300px">

***

**③リガンド抽出**
ウィンドウ上部にて，```Display``` → ```Sequence```を選択しアミノ酸配列を表示させます．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_ligand_1.PNG" width="500px">

スクロールして真ん中くらいのところにいくと，下図のように**NAG**, **4NN**が計4つあると思います．これらを全てドラッグして選択します．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_ligand_2.PNG" width="500px">

選択した4つのうちいずれかひとつを右クリックするとパネルが出てくるので，```actions``` → ```extract object```と選択していきます（下図）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_ligand_3.PNG" width="300px">

すると，選択したリガンドが**obj01**という名前の独立したオブジェクトになります（下図）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_ligand_4.PNG" width="650px">

***

**③リガンドの保存**
ウィンドウ上部にて```File``` → ```Export Molecule...```と選択します（下図）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_ligand_5.PNG" width="300px">

下のように**obj01**を選択した状態で```Save```をクリックし（ほかのオプションは特にいじらなくて大丈夫です），C:\vina\pdb_ligand\に保存します．今回は，**3ayq_ligand.pdb**という名前で保存しました．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/pymol_ligand_6.PNG" width="500px">


***

**④AvogadroでPDBファイルを編集する　その1　D構造の編集（結合の追加，削除，角度変更など）**
ここからは先ほど保存したリガンドのPDBファイル（3ayq_ligand.pdb）をもとに，分子描画および編集ソフトのAvogadroを用いてGalGN3Dを作っていきます．ちなみにGalGN3Dの構造はこんな感じです（[Ogata, M. et al., 2017, Graphical Abstructより](https://doi.org/10.1016/j.ab.2017.09.015)）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/galgn3d_fig.jpg" width="600px">

これを手掛かりに作っていきます

**注意！Avogadroはびっくりするくらいクラッシュするので，これでもかというくらいこまめに上書き保存を心がけてください．これはマジです．最悪の場合保存操作でクラッシュします．気長にやっていきましょう...**

まずはAvogadroを起動し，**3ayq_ligand.pdb**を読み込むと下のようになると思います．赤丸で囲んだ部分がGalGN3Dの"D"（D構造）のもとになる部分です．二重結合の場所や環のゆがみ方などが若干D構造と違うので，編集してD構造にしていきます．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_1.PNG" width="600px">

下図赤丸の星みたいなやつがAvogadroのデフォルトモードです．左ドラッグで回転，右ドラッグで移動，スクロールで拡大縮小ができます．D構造のもとになる部分が編集しやすいように適宜分子の向きや場所を変えます．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_2.PNG" width="600px">

下図赤丸で囲んだ部分が二重結合になっているので，単結合に直します．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_4.PNG" width="600px">

上のツールバーにて，鉛筆のアイコンをクリックすると，左側のパネルが```Draw Settings```となります．これが結合の追加などをするモードです．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_5.PNG" width="600px">

```Element: Carbon```, ```Bond Order: Single```となっているのを確認し，下図の矢印の通り，C原子からN原子，C原子からO原子へなぞるようにして左ドラッグすると二重結合が単結合になります（矢印はレイアウトの都合上ずらしていますが，実際の操作ではマウスカーソルの始点はC原子です）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_6.PNG" width="600px">

念のためこのあたりでいったんセーブしておきましょう．もっと前段階でもいいです．とにかく気づいたらセーブしないとマジでクラッシュして無限に同じ操作をやるはめになります．

次に，C27とC26原子の間を二重結合にします．下図のように，```Bond Order: Double```として，C27からC26へとなぞるように左ドラッグします．多分これで二重結合になるはずです．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_7.PNG" width="600px">

続いて，C29のゆがみ方が反対なので修正します．ツールバーの指アイコンを選択し，C29を左ドラッグして上に持ち上げます．おそらく下図のような向きでやると比較的まっすぐ上がってくれるかと思います．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_8.PNG" width="600px">

上の図を見ると分かるように，C30とO18がとんでもないことになっています．この2原子についても指アイコンモードのまま左ドラッグして自然な位置に持っていきます．あとから構造最適化をかけるのでそこまで厳密にやる必要はないです(下図参照，上からなのでちょっとわかりにくいですが...）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_10.PNG" width="600px">

これで結合次数などは合わせられたので，ここで水素を付加させます．メニューバーの```Build``` → ```Add Hydrogens```を選択すると水素が付きます．
クラッシュが怖いのでまたセーブしておきましょう．D構造っぽいもの（まだ構造最適化をしていないので）がこれで出来上がりました．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_11.PNG" width="300px">

***

**⑤AvogadroでPDBファイルを編集する　その2　Galβ1→4GlcNAcを構築する（末端にGalを結合させる）**
ここまでの段階で，（構造最適化前ではあるものの）GN3Dが出来上がりました．あとはGalを結合させればGalGN3Dになります．

メニューバーにて，```Build``` → ```Insert``` → ```Fragment...``` と選択します（下図）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_12.PNG" width="300px">

```Insert Fragment```ウィンドウが立ち上がるので，```cyclic sugar``` → ```beta-D-galactopyranose.cml```を選択し，```Insert```（下図）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_13.PNG" width="300px">

これで下図のようにGalが挿入されます．遠くの方で青く選択されているオブジェクトがGalです...遠いですね．めちゃくちゃ遠いです．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_14.PNG" width="600px">

そこで，ツールバーで指アイコンを選択し，左ドラッグなどを駆使して末端のGlcNAcにGalを近づけていきます（下図）．ちなみに，右ドラッグで選択された分子のみ回転します．このテクニックも必要になってきます．後は，```Navigation Tool```（ツールバーの星型アイコンをクリックするとそのモードになる）で画面を回転させたりしながらうまいこと近づけていってください．なお，分子の選択ですが，ツールバーの矢印アイコンをクリックすると選択モードになります．ただ，ここでは使わなくて大丈夫です．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_15.PNG" width="600px">

下の図のように，GlcNAcとβ1,4結合が組めそうな位置関係まで持ってこれたらひとまずOKです．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_16.PNG" width="600px">

ツールバーで矢印アイコンをクリックし，Viewerの何もないところ（黒いところ）で右クリックをすると現在選択している分子（今回の場合はGal）の選択が解除されます．その後，Galのアノマー水素を左クリックで選択します．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_17.PNG" width="600px">

```Delete```キーにて選択した水素を削除します．同様にして，Galのアノマー酸素，隣にあるGlcNAcのH1も削除します．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_19.PNG" width="600px">

いよいよグリコシド結合を生成させます．ツールバーの鉛筆アイコンをクリックし，```Element: Oxygen```, ```Bond Order: Single```と設定してから，Galのアノマー炭素からGlcNAcのO2をなぞるように左ドラッグし，グリコシド結合を作ります．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_20.PNG" width="600px">

***

**⑥AvogadroでPDBファイルを編集する　その3　構造最適化（MMFF94）**
これでGalGN3D（っぽい何か）ができましたが，手動でいじった部分がいくつかあるため構造の最適化をする必要があります．まず，ツールバーにて```Extensions``` → ```Molecular Mechanics``` → ```Setup Force Field...```と選択していきます（下図）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_21.PNG" width="300px">

```Setup Force Field```ウィンドウが立ち上がるので，下図のような設定になっていることを確認し，OKをクリックします．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_22.PNG" width="300px">


ツールバーにて，```Extensions``` → ```Optimize Geometry``` と選択し構造最適化を行います（```Ctrl + Alt + O```でも可）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_23.PNG" width="300px">

下のような画面になって構造が最適化されていきます．構造変化がほとんど無くなるまで繰り返します（1回でも十分です）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_25.PNG" width="600px">

**（ここから先の，MOPAC関連の手順は必須ではないですが，手動で構築する箇所が多い構造のために一応行っています．）**

***

**⑦AvogadroでPDBファイルを編集する　その4　MOPAC用インプットファイル作成**
半経験的分子軌道法を用いた構造最適化を行うために，入力ファイルをAvogadroで作成します．メニューバーにて```Extensions```→ ```MOPAC``` と選択していきます．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_26.PNG" width="300px">

```MOPAC Input```ウィンドウが立ち上がるので，下図のように```Method: AM1```に設定し（それ以外はそのままでOKです），```Show Preview```をクリックします．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_27.PNG" width="400px">

プレビュー画面が出てきますので，１行目を**CHARGE=0 AM1 XYZ EF PRECISE MMOK PDBOUT**に置き換えて```Generate```を選択します（下図参照）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/avogadro_28.PNG" width="400px">

今回は，**GalGN3D_fortest.mop**というファイル名で保存しました．

inputファイル（GalGN3D_fortest.mop）は以下のような感じになります．長いので最初の数行のみ載せます．
（1行目の#はコメントなので実際は入力しない）

``` python
CHARGE=0  AM1 XYZ EF PRECISE MMOK PDBOUT  #この1行目が大事．糖の場合はこの設定で大抵大丈夫なはず．
Title

   C  0.000000  1    0.000000  1    0.000000  1        0       0       0   
   C  1.547459  1    0.000000  1    0.000000  1        1       0       0   
   N  1.476537  1  112.817497  1    0.000000  1        2       1       0   
   C  1.541928  1  111.275746  1  237.409904  1        2       1       3   
   O  1.446293  1  109.399468  1  189.415381  1        4       2       1   
   C  1.539993  1  112.146197  1  312.833824  1        4       2       1   
   O  1.437153  1  112.139944  1  166.515978  1        6       4       2   
   C  1.537633  1  109.943252  1   48.514293  1        6       4       2   
   O  1.422931  1  110.756837  1  174.784453  1        1       2       3   
    
 ```  
 
***
 
**⑧MOPAC2016による構造最適化**
先ほど作成したmopファイル（GalGN3D_fortest.mop）を用いて，半経験的分子起動計算ソフトウェアであるMOPAC2016で更なる構造最適化を行います． デスクトップにあるMOPACショートカットと，GalGN3D_fortest.mopが入っているフォルダを開き，隣に並べます．その後，GalGN3D_fortest.mopをドラッグし，MOPAC2016フォルダにある**MOPAC2016.exe**のところに重なったら離します（下図参照）．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/mopac_opendraganddrop.PNG" width="600px">

するとMOPAC2016のウィンドウが立ち上がります．結構前に導入したので下図のような画面が出るかもしれませんが，```Enter```を押すと計算が始まります．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/mopac_2.PNG" width="600px">

計算が始まると以下のような画面になります．何分かで計算が終わり，**GalGN3D_fortest.pdb**が生成されます．

<img src="https://github.com/Haruk-Kono/public_documents/blob/master/dock_manual/mopac_3.PNG" width="600px">

### 設定ファイル (configファイル) の構成
``` julia


receptor=c:\vina\receptor_pdbqt\4HP0_fordock.pdbqt
 
center_x=23.47	
center_y=4.38
center_z=-8.27

size_x=18	
size_y=30
size_z=15

cpu=8

exhaustiveness = 50
num_modes=100
energy_range=3

```

### Cygwinでのドッキングの実行


実際のTerminalはこんな感じになります．手元のデスクトップでやってみたらフリーズしてしまったので，後半のドッキング実行画面～結果のところは過去の計算結果になっています．

```
kubota@ichinose-PC ~
$ cd c:\vina
kubota@ichinose-PC /cygdrive/c/vina
$ ./vinaforcygwin2.sh
 directories list
# kokoni c:\vina\dock_result ni aru foruda ichiran ga hyoji saremasu
 input saved directory (example:'directory_name/' or 'directory_name')
4hp0_test
mkdir: ディレクトリ './4hp0_test' を作成しました
 config files list
# kokoni c:\vina\config ni aru txt no ichiran ga hyuoji saremasu
4hp0_test.txt
 selected config file is '4hp0_test.txt'
 ligand directories list
# kokoni c:\vina\pdbqt_ligand\ ni aru foruda no ichiran ga hyuoji saremasu
 select ligand included directory  (example:'directory_name/' or 'directory_name')
4hp0_test/
 selected directory is '4hp0_test'
GalGN3D_am1.pdbqt
 Processing liand 'GalGN3D_am1'
#################################################################
# If you used AutoDock Vina in your work, please cite:          #
#                                                               #
# O. Trott, A. J. Olson,                                        #
# AutoDock Vina: improving the speed and accuracy of docking    #
# with a new scoring function, efficient optimization and       #
# multithreading, Journal of Computational Chemistry 31 (2010)  #
# 455-461                                                       #
#                                                               #
# DOI 10.1002/jcc.21334                                         #
#                                                               #
# Please see http://vina.scripps.edu for more information.      #
#################################################################

Reading input ... done.
Setting up the scoring function ... done.
Analyzing the binding site ... done.
Using random seed: -315345008
Performing search ...
0%   10   20   30   40   50   60   70   80   90   100%
|----|----|----|----|----|----|----|----|----|----|
***************************************************　　#手元のデスクトップではこの段階（ドッキング実行）でフリーズしました...

Reading input ... done.
Setting up the scoring function ... done.
Analyzing the binding site ... done.
Using random seed: 1979236480
Performing search ... done.
Refining results ... done.

mode |   affinity | dist from best mode
     | (kcal/mol) | rmsd l.b.| rmsd u.b.
-----+------------+----------+----------
   1         -9.2      0.000      0.000
   2         -8.9      1.854      3.538
   3         -8.8      1.840      2.361
   4         -8.8      1.945      3.062
   5         -8.6      1.669      2.956
   6         -8.6      1.894      2.583
   7         -8.5      2.302     13.360
   8         -8.3      3.359     14.474
   9         -8.1      2.916      6.220
  10         -8.1      2.443     13.374
  11         -8.0      1.747      2.211
  12         -8.0      2.659     13.917
  13         -8.0      3.267     14.270
  14         -7.8      2.061     13.497
  15         -7.8      3.329     14.781
  16         -7.8      3.687     14.182
  17         -7.8      3.939     14.777
  18         -7.8      3.995      9.264
  19         -7.7      2.121      3.169
  20         -7.7      3.442     14.503
Writing output ... done.
