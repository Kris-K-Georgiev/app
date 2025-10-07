<?php

namespace App\Services;

class CodeService
{
    public const DEFAULT_LENGTH = 6;
    public const TTL_SECONDS = 600; // 10 минути

    public static function generate(int $length = self::DEFAULT_LENGTH): string
    {
        // Генерираме число и го падваме с водещи нули при нужда (за да позволим и кодове започващи с 0)
        $max = 10 ** $length - 1;
        $num = random_int(0, $max);
        return str_pad((string)$num, $length, '0', STR_PAD_LEFT);
    }

    public static function ttlSeconds(): int
    {
        return self::TTL_SECONDS;
    }

    public static function expiresAt(): \DateTimeImmutable
    {
        return new \DateTimeImmutable('+' . self::TTL_SECONDS . ' seconds');
    }
}
