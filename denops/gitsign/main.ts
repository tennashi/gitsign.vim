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

export function main(denops: Denops): Promise<void> {
  denops.dispatcher = {
    async getSigns(): Promise<Signs> {
      return await getSigns();
    },
  };

  return Promise.resolve();
}
