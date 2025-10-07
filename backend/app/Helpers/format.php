<?php

if (! function_exists('bg_date')) {
    /**
     * Format a date (Carbon|DateTime|string|null) to Bulgarian standard d.m.Y
     */
    function bg_date($value, string $fallback='—'): string
    {
        if (! $value) return $fallback;
        try {
            if (! $value instanceof \Carbon\Carbon) {
                $value = \Carbon\Carbon::parse($value);
            }
            return $value->format('d.m.Y');
        } catch (Throwable $e) {
            return $fallback;
        }
    }
}

if (! function_exists('bg_datetime')) {
    /**
     * Format a date/time to d.m.Y H:i
     */
    function bg_datetime($value, string $fallback='—'): string
    {
        if (! $value) return $fallback;
        try {
            if (! $value instanceof \Carbon\Carbon) {
                $value = \Carbon\Carbon::parse($value);
            }
            return $value->format('d.m.Y H:i');
        } catch (Throwable $e) {
            return $fallback;
        }
    }
}
