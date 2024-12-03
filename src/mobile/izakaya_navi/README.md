# izakaya_navi

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## セットアップ

1. 環境変数の設定:
   ```bash
   # .env.exampleをコピーして.envファイルを作成
   cp .env.example .env
   ```

2. Google Places APIキーの取得:
   - [Google Cloud Console](https://console.cloud.google.com/apis/credentials)にアクセス
   - プロジェクトを作成（または既存のプロジェクトを選択）
   - Places APIを有効化
   - APIキーを作成
   - 作成したAPIキーを`.env`ファイルの`GOOGLE_PLACES_API_KEY`に設定

3. 依存関係のインストール:
   ```bash
   flutter pub get
   ```

4. コード生成の実行:
   ```bash
   flutter pub run build_runner build
   ```

## 注意事項

- `.env`ファイルは決してGitにコミットしないでください
- APIキーは定期的に更新することをお勧めします
- 本番環境では適切なAPIキーの制限（HTTPリファラー、IPアドレスなど）を設定してください
