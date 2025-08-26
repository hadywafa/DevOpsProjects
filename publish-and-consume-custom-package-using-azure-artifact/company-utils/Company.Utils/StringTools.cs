namespace Company.Utils;

public static class StringTools
{
    /// <summary>
    /// Returns the first N characters; if text is shorter, returns text unchanged.
    /// </summary>
    public static string TakeFirst(string text, int count)
        => string.IsNullOrEmpty(text) || count <= 0
            ? string.Empty
            : (text.Length <= count ? text : text[..count]);
}
