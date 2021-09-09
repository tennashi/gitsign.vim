import { Denops, Diff, parse, join } from "./deps.ts";

const getRepositoryRoot = async (): Promise<string> => {
  const process = Deno.run({
    cmd: ["git", "rev-parse", "--show-toplevel"],
    stdout: "piped",
  });

  const output = await process.output();
  const ret = new TextDecoder().decode(output).trim();
  process.close();
  return ret;
};

const getDiff = async (): Promise<string> => {
  const process = Deno.run({
    cmd: [
      "git",
      "-c",
      "diff.noprefix",
      "diff",
      "--no-ext-diff",
      "--no-color",
      "-U0",
    ],
    stdout: "piped",
  });
  const output = await process.output();
  const ret = new TextDecoder().decode(output);
  process.close();

  return ret;
};

type EditType = "delete_first_line" | "delete" | "add" | "change";

type Edit = {
  line: number;
  type: EditType;
};

type FileEdit = {
  fileName: string,
  edits: Edit[],
}

const diffToEdits = (diff: Diff): Edit[] => {
  return diff.hunks.map((hunk): Edit | Edit[] => {
    if (hunk.header.afterStartLine === 0) {
      return {
        line: 1,
        type: "delete_first_line",
      };
    }

    if (hunk.header.afterLines === 0) {
      return {
        line: hunk.header.afterStartLine,
        type: "delete",
      };
    }

    if (hunk.header.beforeLines === 0) {
      return [...Array(hunk.header.afterLines)].map((_, idx) => ({
        line: hunk.header.afterStartLine + idx,
        type: "add",
      }));
    }

    return [...Array(hunk.header.afterLines)].map((_, idx) => ({
      line: hunk.header.afterStartLine + idx,
      type: "change",
    }))
  }).flat();
};

const toSigns = (fileEdits: FileEdit[]): Signs => {
  const signs: Signs = {}

  fileEdits.forEach((fileEdit) => {
    signs[fileEdit.fileName] = {}

    fileEdit.edits.forEach((edit) => {
      signs[fileEdit.fileName][edit.line] = toSignType(edit.type)
    })
  })

  return signs;
}

const getSigns = async (): Promise<Signs> => {
  const gitRepoRoot = await getRepositoryRoot();
  const gitDiff = await getDiff();
  const parsed = parse(gitDiff);

  const signs: Signs = {}

  parsed.forEach((diff) => {
    signs[join(gitRepoRoot, diff.afterFileName)] = toSignLines(diff)
  })

  return signs;
};

type SignType = "GitsignDeleteFirstLine" | "GitsignDelete" | "GitsignAdd" | "GitsignChange"

type Signs = {
  [key: string]: {
    [key: number]: SignType
  }
}

type SignLines = {
  [key: number]: SignType
}

const toSignLines = (diff: Diff): SignLines => {
  const signs: SignLines = {}

  diff.hunks.forEach((hunk) => {
    if (hunk.header.afterStartLine === 0) {
      signs[1] = "GitsignDeleteFirstLine";
      return;
    }

    if (hunk.header.afterLines === 0) {
      signs[hunk.header.afterStartLine] = "GitsignDelete";
      return;
    }

    if (hunk.header.beforeLines === 0) {
      [...Array(hunk.header.afterLines)].forEach((_, idx) => {
        signs[hunk.header.afterStartLine + idx] = "GitsignAdd";
      });
      return;
    }

    [...Array(hunk.header.afterLines)].forEach((_, idx) => {
      signs[hunk.header.afterStartLine + idx] = "GitsignChange";
    });
    return;
  });

  return signs;
};

const toSignType = (editType: EditType): SignType => {
  switch (editType) {
    case "delete_first_line":
      return "GitsignDeleteFirstLine";
    case "delete":
      return "GitsignDelete";
    case "add":
      return "GitsignAdd";
    case "change":
      return "GitsignChange";
  }
}

export function main(denops: Denops): Promise<void> {
  denops.dispatcher = {
    async getSigns(): Promise<Signs> {
      return await getSigns();
    },
  };

  return Promise.resolve();
}
