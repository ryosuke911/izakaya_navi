# izakaya_navi

居酒屋検索アプリケーション

## セットアップ

1. 環境変数の設定:
   ```bash
   # .env.exampleをコピーして.envファイルを作成
   cp .env.example .env
   ```

2. ホットペッパーグルメAPIキーの取得:
   - [リクルートWebサービス](https://webservice.recruit.co.jp/register)にアクセス
   - 会員登録を行う
   - APIキーを発行
   - 作成したAPIキーを`.env`ファイルの`HOTPEPPER_API_KEY`に設定

3. 依存関係のインストール:
   ```bash
   flutter pub get
   ```

4. コード生成の実行:
   ```bash
   flutter pub run build_runner build
   ```

## 機能

- 居酒屋の検索（キーワード、エリア、ジャンルなど）
- 現在地周辺の居酒屋検索
- 詳細な条件での絞り込み（予算、人数、設備など）
- 店舗の詳細情報の表示
- Google Mapsでの位置確認
- ホットペッパーグルメへのリンク

## 注意事項

- `.env`ファイルは決してGitにコミットしないでください
- APIキーは定期的に更新することをお勧めします
- 本番環境では適切なAPIキーの制限を設定してください
