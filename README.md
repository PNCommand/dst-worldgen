# dst-worldgen

## Usage

These scripts can extract the configuration options used by worldgenoverride.lua from the DST server files.  
The output is files with JSON format.  
Command `unzip` and `lua` is required.

```bash
git clone https://github.com/PNCommand/dst-worldgen.git
cd dst-worldgen
chmod u+x ./main.sh

# ./main.sh "/{path_to_dst_server_dir}/data/databundles/scripts.zip" "language_code"
./main.sh /root/server/data/databundles/scripts.zip en
```

By default, the output files will be saved in the `output` folder in the root directory of this repository.  
You can also modify the constant `output_dir` in `main.sh` to change the location.

## 用法

这个脚本可以从DST服务端文件里面提取出worldgenoverride.lua里所用到的配置，并输出为JSON文件。  
执行脚本需要`unzip`和`lua`。

```bash
git clone https://github.com/PNCommand/dst-worldgen.git
cd dst-worldgen
chmod u+x ./main.sh

# ./main.sh "/{到DST服务端文件夹的路径}/data/databundles/scripts.zip" "语言代码"
./main.sh /root/server/data/databundles/scripts.zip zh-CN
```

默认配置下，输出的文件会保存在仓库根目录的`output`文件夹里面。  
你也可以修改`main.sh`里面的常量`output_dir`来更改输出位置。

## 使い方

これらのスクリプトは、DSTサーバファイルから、worldgenoverride.luaで使われる設定を抽出して、JSONファイルに出力できます。  
実行するには`unzip`と`lua`が必要です。

```bash
git clone https://github.com/PNCommand/dst-worldgen.git
cd dst-worldgen
chmod u+x ./main.sh

# ./main.sh "/{DSTサーバディレクトリまでのパス}/data/databundles/scripts.zip" "言語コード"
./main.sh /root/server/data/databundles/scripts.zip ja
```

デフォルトでは、出力先はリポジトリルートにある`output`になります。  
`main.sh`の中の定数`output_dir`を変えることで出力先を変更できます。
