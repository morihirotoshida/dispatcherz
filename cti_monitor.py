import serial
import time
import re
import sys

# ★STEP 1で確認したポート名に変更してください（例: /dev/ttyACM0）
MODEM_PORT = '/dev/ttyACM0'
BAUD_RATE = 9600

def main():
    print(f"[{MODEM_PORT}] モデムの着信監視をスタートします...")
    try:
        # シリアルポートを開く
        ser = serial.Serial(MODEM_PORT, BAUD_RATE, timeout=1)
        
        # ナンバーディスプレイ（着信番号通知）を有効化するATコマンドを送信
        # IODATA等の一般的なアナログモデムは「AT+VCID=1」でナンバーディスプレイがONになります
        ser.write(b'AT+VCID=1\r\n')
        time.sleep(1)

        print("監視中... (Ctrl+C で終了)")

        while True:
            # モデムからの信号を1行ずつ読み取る
            line = ser.readline().decode('ascii', errors='ignore').strip()
            
            if line:
                # print(f"モデム生信号: {line}") # デバッグ用: モデムの生データを見たい場合はこの行の先頭の#を消してください

                # 「NMBR = 09012345678」や「NMBR=09012345678」という文字列から番号だけを抽出
                match = re.search(r'NMBR\s*=\s*(\d+)', line)
                if match:
                    phone_number = match.group(1)
                    print(f"\n📞 着信を検知しました！ 番号: {phone_number}")

                    # Flutter（dispatcherZ）が監視しているファイルに番号を書き込む
                    file_path = '/tmp/dispatcherz_incoming.txt'
                    with open(file_path, 'w') as f:
                        f.write(phone_number)
                    
                    print(f"[{file_path}] に着信データを書き込み、dispatcherZにパスしました。")

    except serial.SerialException as e:
        print(f"\n❌ エラー: モデムに接続できませんでした。")
        print(f"1. モデムが {MODEM_PORT} に繋がっているか確認してください。")
        print(f"2. 権限がない場合は、ターミナルで「sudo chmod 666 {MODEM_PORT}」を実行してから再試行してください。")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n監視を終了します。")
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()

if __name__ == '__main__':
    main()