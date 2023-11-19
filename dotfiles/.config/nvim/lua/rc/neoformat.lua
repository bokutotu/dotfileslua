local autocmd = vim.api.nvim_create_autocmd

autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        vim.cmd("Neoformat")
    end
})

-- Rustフォーマッター（rustfmt）のパスを指定
local rustfmt_path = "~/.cargo/bin/rustfmt"  -- 実際のrustfmtのパスに置き換えてください

-- Rustファイルの保存時にNeoformatを実行
autocmd("BufWritePre", {
    pattern = "*.rs",
    callback = function()
        -- Neoformatの設定を一時的に変更
        vim.g.neoformat_rust_rustfmt = {
            exe = rustfmt_path,
            args = {"--edition", "2018"},
            replace = 1
        }
        vim.cmd("Neoformat")
    end
})

-- その他のファイルタイプの保存時にもNeoformatを実行
autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        -- Rustファイル以外では、デフォルトの設定を使用
        if vim.bo.filetype ~= "rust" then
            vim.cmd("Neoformat")
        end
    end
})

