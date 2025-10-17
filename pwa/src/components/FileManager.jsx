import { useEffect, useState } from 'react'
import { Button, Table, FileInput, Card } from 'flowbite-react'
import { listMyFiles, uploadFile } from '../services/drive'

export default function FileManager() {
  const [files, setFiles] = useState([])
  const [busy, setBusy] = useState(false)

  const refresh = async () => {
    setBusy(true)
    try { setFiles(await listMyFiles()) } finally { setBusy(false) }
  }

  useEffect(() => { refresh() }, [])

  const onUpload = async (e) => {
    const f = e.target.files?.[0]
    if (!f) return
    setBusy(true)
    try {
      const ab = await f.arrayBuffer()
      await uploadFile({ name: f.name, mimeType: f.type || 'application/octet-stream', data: ab })
      await refresh()
    } finally { setBusy(false); e.target.value = '' }
  }

  return (
    <div className="space-y-4">
      <Card>
        <div className="flex items-center gap-2">
          <FileInput onChange={onUpload} disabled={busy} />
          <Button onClick={refresh} isProcessing={busy}>Опресни</Button>
        </div>
      </Card>
      <div className="overflow-x-auto">
        <Table>
          <Table.Head>
            <Table.HeadCell>Име</Table.HeadCell>
            <Table.HeadCell>Тип</Table.HeadCell>
            <Table.HeadCell>Променен</Table.HeadCell>
            <Table.HeadCell>Отвори</Table.HeadCell>
          </Table.Head>
          <Table.Body className="divide-y">
            {files.map(f => (
              <Table.Row key={f.id}>
                <Table.Cell>{f.name}</Table.Cell>
                <Table.Cell>{f.mimeType}</Table.Cell>
                <Table.Cell>{new Date(f.modifiedTime).toLocaleString()}</Table.Cell>
                <Table.Cell>
                  <a className="text-sky-500" href={f.webViewLink} target="_blank" rel="noreferrer">View</a>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table.Body>
        </Table>
      </div>
    </div>
  )
}
