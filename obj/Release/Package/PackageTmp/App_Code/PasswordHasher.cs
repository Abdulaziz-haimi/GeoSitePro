using System;
using System.Security.Cryptography;

public static class PasswordHasher
{
    private const int SaltSize = 16;
    private const int HashSize = 32;
    private const int Iterations = 100000;

    public static void CreatePasswordHash(string password, out string passwordHash, out string passwordSalt)
    {
        if (string.IsNullOrWhiteSpace(password))
            throw new ArgumentException("Password is required.", "password");

        byte[] saltBytes = new byte[SaltSize];

        using (var rng = new RNGCryptoServiceProvider())
        {
            rng.GetBytes(saltBytes);
        }

        byte[] hashBytes = GenerateHash(password, saltBytes);
        passwordSalt = Convert.ToBase64String(saltBytes);
        passwordHash = Convert.ToBase64String(hashBytes);
    }

    public static bool VerifyPassword(string password, string storedHash, string storedSalt)
    {
        if (string.IsNullOrWhiteSpace(password)) return false;
        if (string.IsNullOrWhiteSpace(storedHash) || string.IsNullOrWhiteSpace(storedSalt)) return false;

        byte[] saltBytes;
        byte[] storedHashBytes;

        try
        {
            saltBytes = Convert.FromBase64String(storedSalt);
            storedHashBytes = Convert.FromBase64String(storedHash);
        }
        catch
        {
            return false;
        }

        byte[] computedHashBytes = GenerateHash(password, saltBytes);
        return FixedTimeEquals(storedHashBytes, computedHashBytes);
    }

    private static byte[] GenerateHash(string password, byte[] saltBytes)
    {
        using (var pbkdf2 = new Rfc2898DeriveBytes(password, saltBytes, Iterations))
        {
            return pbkdf2.GetBytes(HashSize);
        }
    }

    private static bool FixedTimeEquals(byte[] a, byte[] b)
    {
        if (a == null || b == null) return false;
        if (a.Length != b.Length) return false;

        int diff = 0;
        for (int i = 0; i < a.Length; i++) diff |= a[i] ^ b[i];
        return diff == 0;
    }
}
