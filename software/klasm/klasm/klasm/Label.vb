Public Class Label
    Public name As String
    Public address As Int64
    Public slot As Integer
    Public defined As Boolean
    Public PatchAddresses As Collection

    Public Sub New()
        PatchAddresses = New Collection
    End Sub
End Class
